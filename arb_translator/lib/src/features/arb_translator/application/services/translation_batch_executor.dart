import 'dart:async';

import 'package:arb_translator/src/core/services/log_service.dart';
import 'package:arb_translator/src/features/arb_translator/application/services/batch_translation_runner.dart';
import 'package:arb_translator/src/features/arb_translator/domain/services/translation_cells.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_errors_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_settings_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_strategy_registry.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/locale_translation_progress_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_controller.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/translation_progress_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:arb_translator/src/features/arb_translator/application/services/batch_translation_runner.dart'
    show kTranslationBatchSize;

/// Encapsulates bulk AI translation logic with batch processing.
/// Uses structured output (JSON schema) for efficient translation of multiple strings.
class TranslationBatchExecutor {
  TranslationBatchExecutor(this.ref);
  final Ref ref;

  Future<void> run({required String targetLocale, required bool onlyEmpty}) async {
    logInfo('Starting batch translation: locale=$targetLocale, onlyEmptyOrChanged=$onlyEmpty');

    final controller = ref.read(projectControllerProvider);
    final baseLocale = controller.baseLocale;
    if (targetLocale == baseLocale) {
      logWarning('Skipping translation to base locale: $targetLocale');
      return;
    }

    final settingsNotifier = ref.read(aiSettingsProvider.notifier);
    final apiKey = await settingsNotifier.readFullKey();
    if (apiKey == null || apiKey.isEmpty) {
      logWarning('No API key available for batch translation');
      return;
    }

    final glossary = ref.read(aiSettingsProvider).glossaryPrompt;
    final strategy = ref.read(currentAiStrategyProvider);
    final entries = controller.entries;

    // In onlyEmpty mode: keys with no translation OR whose EN source has changed
    // (so stale translations get refreshed automatically alongside empty ones).
    final candidates = TranslationCells.translationCandidates(
      entries: entries,
      baseLocale: baseLocale,
      targetLocale: targetLocale,
      onlyMissing: onlyEmpty,
      staleCells: controller.staleCells,
    );

    if (candidates.isEmpty) {
      logInfo('No candidates for translation');
      return;
    }

    logInfo('Found ${candidates.length} entries for batch translation (total entries: ${entries.length})');

    // Initialize progress for this locale
    final localeProgress = ref.read(localeTranslationProgressProvider.notifier);
    final globalProgress = ref.read(translationProgressProvider.notifier);

    // Clear previous errors
    ref.read(aiErrorsProvider.notifier).clear();

    // Start progress
    localeProgress.start(targetLocale, candidates.length);
    globalProgress.start(candidates.length);

    var totalProcessed = 0;
    void advance(int count) {
      totalProcessed += count;
      localeProgress.updateProgress(targetLocale, totalProcessed);
      globalProgress.updateDone(totalProcessed);
    }

    await BatchTranslationRunner(strategy: strategy, apiKey: apiKey, glossaryPrompt: glossary).run(
      candidates: candidates,
      baseLocale: baseLocale,
      targetLocale: targetLocale,
      isCancelled: () {
        final cancelled = ref.read(localeTranslationProgressProvider).isCancelRequested(targetLocale);
        if (cancelled) logInfo('Batch translation cancelled by user after $totalProcessed item(s)');
        return cancelled;
      },
      onBatchTranslated: (batch, translations) {
        final projectController = ref.read(projectControllerProvider.notifier);
        for (final entry in batch) {
          final translation = translations[entry.key];
          if (translation != null) {
            projectController.updateCell(key: entry.key, locale: targetLocale, text: translation);
            logDebug(
              'Applied translation: ${entry.key} -> "${translation.substring(0, translation.length.clamp(0, 50))}..."',
            );
          } else {
            logWarning('Missing translation for key: ${entry.key}');
            ref
                .read(aiErrorsProvider.notifier)
                .add(key: entry.key, locale: targetLocale, message: 'No translation received from AI');
          }
        }
        advance(batch.length);
        logDebug('Batch completed: ${translations.length}/${batch.length} translations applied');
      },
      onBatchFailed: (batch, error, stackTrace) {
        logError('Batch of ${batch.length} failed', error, stackTrace);
        for (final entry in batch) {
          ref
              .read(aiErrorsProvider.notifier)
              .add(key: entry.key, locale: targetLocale, message: 'Batch translation failed: $error');
        }
        // Update progress even on error
        advance(batch.length);
      },
    );

    final finalProgress = ref.read(localeTranslationProgressProvider).getProgress(targetLocale);
    logInfo(
      'Batch translation completed: processed ${finalProgress?.done ?? totalProcessed}/${candidates.length} items',
    );

    // Finish progress
    localeProgress.finish(targetLocale);
    globalProgress.finish();
  }
}

final translationBatchExecutorProvider = Provider<TranslationBatchExecutor>(TranslationBatchExecutor.new);
