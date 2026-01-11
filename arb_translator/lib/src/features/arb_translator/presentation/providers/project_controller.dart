import 'dart:convert';
import 'dart:io';

import 'package:arb_translator/src/core/services/log_service.dart';
import 'package:arb_translator/src/core/utils/hash_utils.dart';
import 'package:arb_translator/src/features/arb_translator/application/services/translation_batch_executor.dart';
import 'package:arb_translator/src/features/arb_translator/application/undo/commands.dart';
import 'package:arb_translator/src/features/arb_translator/application/validation/placeholder_validator.dart';
import 'package:arb_translator/src/features/arb_translator/data/datasources/arb_file_datasource.dart';
import 'package:arb_translator/src/features/arb_translator/data/repositories/translation_repository_impl.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';
import 'package:arb_translator/src/features/arb_translator/domain/usecases/load_arb_folder.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/active_cell_translation_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_errors_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_providers.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_settings_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/notifications_provider.dart';
// ignore_for_file: undefined_identifier
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_state.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/translation_progress_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/undo_provider.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// (Notification UI handled externally; controller stays pure.)

part 'project_controller.g.dart';

@Riverpod(keepAlive: true)
class ProjectController extends _$ProjectController {
  @override
  ProjectState build() => const ProjectState();

  static final Logger _log = Logger();

  Future<void> loadFolder(String path, {bool rethrowOnError = false}) async {
    logInfo('Starting to load folder: $path');
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true);
    try {
      final repo = TranslationRepositoryImpl(ArbFileDataSource());
      final loader = LoadArbFolder(repo);
      final (baseLocale, locales, entries) = await loader(path);
      logInfo(
        'Loaded folder successfully: $path, base: $baseLocale, locales: ${locales.length}, entries: ${entries.length}',
      );

      if (!ref.mounted) return;
      // Read raw base locale file (if present) so we can distinguish true orphans (keys absent
      // from base file) from keys that are present but empty. This fixes previous heuristic that
      // missed empty-but-present keys.
      Set<String> baseKeys = <String>{};
      final Set<String> sourceChangedKeys = <String>{};
      try {
        final normalizedPath = path.endsWith(Platform.pathSeparator) ? path.substring(0, path.length - 1) : path;
        final baseFile = File('$normalizedPath${Platform.pathSeparator}app_$baseLocale.arb');
        // ignore: avoid_slow_async_io (single existence check during initial load)
        if (await baseFile.exists()) {
          // ignore: avoid_slow_async_io (single read on load acceptable)
          final raw = json.decode(await baseFile.readAsString()) as Map<String, dynamic>;
          baseKeys = raw.keys.where((k) => !k.startsWith('@') && k != '@@locale').cast<String>().toSet();

          // Check for source changes based on stored hashes
          for (final entry in entries) {
            final currentText = entry.values[baseLocale] ?? '';
            if (currentText.isNotEmpty && HashUtils.isSourceChanged(currentText, entry.meta.sourceHash)) {
              sourceChangedKeys.add(entry.key);
              logInfo('Source changed detected for key: ${entry.key}');
            }
          }
        } else {
          logWarning('Base locale file not found when computing baseLocaleKeys: ${baseFile.path}');
        }
      } catch (e, st) {
        logError('Failed to parse base locale file for keys', e, st);
      }

      state = state.copyWith(
        folderPath: path,
        baseLocale: baseLocale,
        locales: locales,
        entries: entries,
        baseLocaleKeys: baseKeys,
        sourceChangedKeys: sourceChangedKeys,
        isLoading: false,
        hasUnsavedChanges: false,
        dirtyCells: <(String, String)>{},
        dirtyLocales: <String>{},
        searchQuery: '', // Clear search when loading new folder
      );
      if (ref.mounted) {
        ref.read(aiErrorsProvider.notifier).clear();
      }
    } catch (e, st) {
      if (ref.mounted) {
        state = state.copyWith(isLoading: false);
      }
      logError('Failed to load folder: $path', e, st);
      _log.e('Failed to load folder $path', error: e, stackTrace: st);
      if (rethrowOnError) rethrow;
    }
  }

  void updateCell({required String key, required String locale, required String text}) {
    logDebug('Updating cell: key=$key, locale=$locale, text length=${text.length}');
    // Find entry index
    final idx = state.entries.indexWhere((e) => e.key == key);
    if (idx == -1) {
      logWarning('Key not found for update: $key');
      return; // key not found
    }

    final entry = state.entries[idx];
    final oldVal = entry.values[locale] ?? '';
    if (oldVal == text) return; // no change

    // Update entry values map immutably
    final newValues = Map<String, String>.from(entry.values)..[locale] = text;
    final newEntry = entry.copyWith(values: newValues);

    // Rebuild entries list
    final newEntries = [...state.entries]..[idx] = newEntry;

    const validator = PlaceholderValidator();
    final newErrorCells = validator.validateCell(
      entry: newEntry,
      locale: locale,
      baseLocale: state.baseLocale,
      allEntries: state.entries,
      previousErrors: state.errorCells,
    );

    // Dirty tracking
    final newDirtyCells = Set<(String, String)>.from(state.dirtyCells)..add((key, locale));
    final newDirtyLocales = Set<String>.from(state.dirtyLocales)..add(locale);

    final prevState = state;

    // Optimize: avoid recreating state if hasUnsavedChanges is already true
    // and only that flag would change
    final needsUnsavedFlag = !state.hasUnsavedChanges;

    final nextState = state.copyWith(
      entries: newEntries,
      dirtyCells: newDirtyCells,
      dirtyLocales: newDirtyLocales,
      hasUnsavedChanges: needsUnsavedFlag || state.hasUnsavedChanges,
      errorCells: newErrorCells,
      lastEditedCell: (key, locale),
    );
    state = nextState;
    // Push undo action
    ref
        .read(undoManagerProvider)
        .push(UpdateCellCommand(apply: () => state = nextState, revert: () => state = prevState));
  }

  void renameKey({required String oldKey, required String newKey}) {
    if (oldKey == newKey) return;
    if (newKey.trim().isEmpty) return;
    if (state.entries.any((e) => e.key == newKey)) {
      // uniqueness enforced - in future surface error
      return;
    }
    final updated = <TranslationEntry>[];
    for (final e in state.entries) {
      if (e.key == oldKey) {
        updated.add(e.copyWith(key: newKey));
      } else {
        updated.add(e);
      }
    }
    // Update dirty & error sets (rename key portion)
    final newDirtyCells = <(String, String)>{
      for (final c in state.dirtyCells)
        if (c.$1 == oldKey) (newKey, c.$2) else c,
      for (final l in state.locales) (newKey, l), // mark all renamed cells dirty
    };
    final newErrorCells = <(String, String)>{
      for (final c in state.errorCells)
        if (c.$1 == oldKey) (newKey, c.$2) else c,
    };
    final prev = state;
    final next = state.copyWith(
      entries: updated,
      dirtyCells: newDirtyCells,
      hasUnsavedChanges: true,
      errorCells: newErrorCells,
      lastEditedCell: (newKey, state.baseLocale),
    );
    state = next;
    ref.read(undoManagerProvider).push(RenameKeyCommand(apply: () => state = next, revert: () => state = prev));
  }

  void deleteKey(String key) {
    final updated = state.entries.where((e) => e.key != key).toList();
    if (updated.length == state.entries.length) return; // nothing removed
    final newDirtyCells = <(String, String)>{...state.dirtyCells.where((c) => c.$1 != key)};
    final newErrorCells = <(String, String)>{...state.errorCells.where((c) => c.$1 != key)};
    // Mark deletion by setting unsaved changes; actual removal already done.
    final prev = state;
    final next = state.copyWith(
      entries: updated,
      dirtyCells: newDirtyCells,
      errorCells: newErrorCells,
      hasUnsavedChanges: true,
      lastEditedCell: (key, state.baseLocale),
    );
    state = next;
    ref.read(undoManagerProvider).push(DeleteKeyCommand(apply: () => state = next, revert: () => state = prev));
  }

  /// Removes all entries that are missing an English (base locale) value – i.e. keys
  /// that exist only in non-English locale files. This keeps the invariant that
  /// every persisted key must exist (even empty) in the base locale file.
  /// Marks deletions as a single undoable action.
  void removeKeysMissingInEnglish() {
    if (state.entries.isEmpty) {
      logInfo('Orphan cleanup: no entries present, nothing to remove.');
      return;
    }
    final base = state.baseLocale;
    final original = state.entries;
    // New semantics: remove
    // 1) keys absent from the original base (en) file (baseLocaleKeys)
    // 2) keys whose English value is empty (after trim)
    final baseKeys = state.baseLocaleKeys; // Can be empty if base file not parsed

    final toRemove = <String>[];
    for (final e in original) {
      final enVal = (e.values[base] ?? '').trim();
      final isMissingInBaseFile = baseKeys.isNotEmpty && !baseKeys.contains(e.key);
      final isEmptyEnglish = enVal.isEmpty;
      if (isMissingInBaseFile || isEmptyEnglish) {
        toRemove.add(e.key);
      }
    }

    if (toRemove.isEmpty) {
      logInfo('Orphan cleanup: nothing to remove. baseKeys=${baseKeys.length} entries=${original.length}');
      ref.read(notificationMessageProvider.notifier).message = 'No orphan or empty-English keys';
      return;
    }

    final previewList = toRemove.take(20).join(', ');
    final truncated = toRemove.length > 20 ? ' ...(+${toRemove.length - 20})' : '';
    logInfo(
      'Removing ${toRemove.length} key(s) (missing in base file or empty English). First up to 20: $previewList$truncated',
    );

    final filtered = original.where((e) => !toRemove.contains(e.key)).toList();
    // Clean dirty / error sets
    final newDirty = <(String, String)>{
      for (final c in state.dirtyCells)
        if (!toRemove.contains(c.$1)) c,
    };
    final newErrors = <(String, String)>{
      for (final c in state.errorCells)
        if (!toRemove.contains(c.$1)) c,
    };
    final prev = state;
    final next = state.copyWith(
      entries: filtered,
      dirtyCells: newDirty,
      errorCells: newErrors,
      hasUnsavedChanges: true,
      lastEditedCell: (toRemove.first, base),
    );
    state = next;
    ref.read(undoManagerProvider).push(DeleteKeyCommand(apply: () => state = next, revert: () => state = prev));
    ref.read(notificationMessageProvider.notifier).message = 'Removed ${toRemove.length} key(s)';
  }

  /// Removes all entries whose English (base locale) value is empty (after trim).
  /// This is useful to clean up placeholder / accidentally created keys with no
  /// source text. Aggregated as a single undo step.
  void removeKeysWithEmptyEnglish() {
    if (state.entries.isEmpty) {
      logInfo('Empty-English cleanup: no entries present.');
      return;
    }
    final base = state.baseLocale;
    final original = state.entries;
    final toRemove = <String>[
      for (final e in original)
        if ((e.values[base] ?? '').trim().isEmpty) e.key,
    ];
    if (toRemove.isEmpty) {
      // Add sample for diagnostics: show first 5 non-empty values.
      final sample = original
          .take(5)
          .map((e) => '${e.key}="${(e.values[base] ?? '').replaceAll('\n', ' ')}"')
          .join('; ');
      logInfo('Empty-English cleanup: nothing to remove. Checked=${original.length}. Sample: $sample');
      ref.read(notificationMessageProvider.notifier).message = 'No empty English keys';
      return;
    }
    final previewList = toRemove.take(20).join(', ');
    final truncated = toRemove.length > 20 ? ' ...(+${toRemove.length - 20})' : '';
    logInfo('Removing ${toRemove.length} keys with empty English value. First up to 20: $previewList$truncated');
    final filtered = original.where((e) => !toRemove.contains(e.key)).toList();
    final newDirty = <(String, String)>{
      for (final c in state.dirtyCells)
        if (!toRemove.contains(c.$1)) c,
    };
    final newErrors = <(String, String)>{
      for (final c in state.errorCells)
        if (!toRemove.contains(c.$1)) c,
    };
    final prev = state;
    final next = state.copyWith(
      entries: filtered,
      dirtyCells: newDirty,
      errorCells: newErrors,
      hasUnsavedChanges: true,
      lastEditedCell: (toRemove.first, base),
    );
    state = next;
    ref.read(undoManagerProvider).push(DeleteKeyCommand(apply: () => state = next, revert: () => state = prev));
    ref.read(notificationMessageProvider.notifier).message = 'Removed ${toRemove.length} empty English key(s)';
  }

  Future<void> saveAll() async {
    if (state.folderPath == null) {
      logWarning('Cannot save: no folder path set');
      return;
    }

    logInfo('Starting save all files to: ${state.folderPath}');
    state = state.copyWith(isSaving: true);

    try {
      final ds = ArbFileDataSource();
      final base = state.baseLocale;

      for (final locale in state.locales) {
        logDebug('Saving locale file: $locale');
        final data = ds.serializeLocale(entries: state.entries, locale: locale, baseLocale: base);
        await ds.writeArb(folderPath: state.folderPath!, locale: locale, data: data);
      }

      state = state.copyWith(
        isSaving: false,
        dirtyCells: <(String, String)>{},
        dirtyLocales: <String>{},
        hasUnsavedChanges: false,
        lastSavedAt: DateTime.now(),
      );

      // Clear undo stack after successful save by draining redo/undo history
      ref.read(undoManagerProvider).clear();

      logInfo('Save completed successfully. Saved ${state.locales.length} locale files');
      // Show success notification via context if available
      // Note: This will be handled in the UI layer that observes the state change
    } catch (e, st) {
      logError('Failed to save files', e, st);
      state = state.copyWith(isSaving: false);
      // Surface error later via UI.
    }
  }

  Future<void> translateCell({required String key, required String locale}) async {
    logInfo('Starting cell translation: key=$key, locale=$locale');

    // Skip if base locale or no api key
    if (locale == state.baseLocale) {
      logDebug('Skipping translation for base locale: $locale');
      return;
    }

    final settingsNotifier = ref.read(aiSettingsProvider.notifier);
    final apiKey = await settingsNotifier.readFullKey();
    if (apiKey == null || apiKey.isEmpty) {
      logWarning('No API key available for translation');
      return;
    }

    final glossary = ref.read(aiSettingsProvider).glossaryPrompt;
    final strategy = ref.read(aiStrategyProvider);

    final entry = state.entries.firstWhere((e) => e.key == key, orElse: () => throw Exception('Key not found'));
    final english = entry.values[state.baseLocale] ?? '';
    if (english.isEmpty) {
      logWarning('Empty English text for key: $key');
      return;
    }

    logDebug('Translating text: "$english" to $locale using strategy: ${strategy.runtimeType}');

    // Mark translating cell via separate provider
    ref.read(activeCellTranslationProvider.notifier).state = (key, locale);
    try {
      final translated = await strategy.translate(
        apiKey: apiKey,
        englishText: english,
        targetLocale: locale,
        description: entry.meta.description,
        glossaryPrompt: glossary,
      );

      logInfo('Translation successful: key=$key, locale=$locale, result: "$translated"');
      updateCell(key: key, locale: locale, text: translated);
    } catch (e, st) {
      logError('Translation failed: key=$key, locale=$locale', e, st);
      ref.read(aiErrorsProvider.notifier).add(key: key, locale: locale, message: 'Failed to translate cell');
    } finally {
      // Clear indicator (only if still same cell)
      final active = ref.read(activeCellTranslationProvider);
      if (active == (key, locale)) {
        ref.read(activeCellTranslationProvider.notifier).state = null;
      }
    }
  }

  Future<void> translateBulk({required String locale, required bool onlyEmpty}) async {
    await ref.read(translationBatchExecutorProvider).run(targetLocale: locale, onlyEmpty: onlyEmpty);
  }

  void cancelTranslation() {
    final n = ref.read(translationProgressProvider.notifier);
    final st = ref.read(translationProgressProvider);
    if (!st.cancelRequested && st.isTranslating) n.cancel();
  }

  void toggleFilterErrors() {
    state = state.copyWith(showOnlyErrors: !state.showOnlyErrors);
  }

  void toggleFilterUntranslated() {
    state = state.copyWith(showOnlyUntranslated: !state.showOnlyUntranslated);
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.trim().toLowerCase());
  }

  void undo() {
    final mgr = ref.read(undoManagerProvider);
    if (mgr.canUndo) mgr.undo();
  }

  void redo() {
    final mgr = ref.read(undoManagerProvider);
    if (mgr.canRedo) mgr.redo();
  }

  /// Update source hashes for all entries with current base locale text
  /// This should be called after translating changed source entries
  void commitSourceHashes() {
    logInfo('Committing source hashes for all entries');

    final updatedEntries = <TranslationEntry>[];
    final baseLocale = state.baseLocale;

    for (final entry in state.entries) {
      final sourceText = entry.values[baseLocale] ?? '';
      if (sourceText.isNotEmpty) {
        final newHash = HashUtils.computeSourceHash(sourceText);
        final updatedMeta = entry.meta.copyWith(sourceHash: newHash);
        updatedEntries.add(entry.copyWith(meta: updatedMeta));
      } else {
        updatedEntries.add(entry);
      }
    }

    state = state.copyWith(
      entries: updatedEntries,
      sourceChangedKeys: <String>{}, // Clear all source changed keys
      hasUnsavedChanges: true, // Mark as needing save
    );

    logInfo('Source hashes committed for ${updatedEntries.length} entries');
  }
}
