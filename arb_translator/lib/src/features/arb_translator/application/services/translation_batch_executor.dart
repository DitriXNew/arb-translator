import 'dart:async';

import 'package:arb_translator/src/core/services/log_service.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_errors_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_settings_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_strategy_registry.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_controller.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/translation_progress_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Encapsulates bulk AI translation logic (single responsibility, testable).
class TranslationBatchExecutor {
  TranslationBatchExecutor(this.ref);
  final Ref ref;

  Future<void> run({required String targetLocale, required bool onlyEmpty}) async {
    logInfo('Starting batch translation: locale=$targetLocale, onlyEmpty=$onlyEmpty');

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

    final candidates = <TranslationEntry>[
      for (final e in entries)
        if ((e.values[baseLocale] ?? '').isNotEmpty)
          if (!onlyEmpty || (e.values[targetLocale] ?? '').isEmpty) e,
    ];

    logInfo('Found ${candidates.length} entries for batch translation (total entries: ${entries.length})');

    final progress = ref.read(translationProgressProvider.notifier);
    // Clear previous AI errors before starting a new batch
    ref.read(aiErrorsProvider.notifier).clear();
    progress.start(candidates.length);

    for (final e in candidates) {
      final st = ref.read(translationProgressProvider);
      if (st.cancelRequested) {
        logInfo('Batch translation cancelled by user');
        break;
      }
      final english = e.values[baseLocale] ?? '';
      try {
        final translated = await strategy.translate(
          apiKey: apiKey,
          englishText: english,
          targetLocale: targetLocale,
          description: e.meta.description,
          glossaryPrompt: glossary,
        );
        ref.read(projectControllerProvider.notifier).updateCell(key: e.key, locale: targetLocale, text: translated);
        logDebug('Batch translated: ${e.key} -> "$translated"');
      } catch (ex) {
        // collect single cell errors, continue
        logWarning('Batch translation failed for ${e.key}', ex);
        ref.read(aiErrorsProvider.notifier).add(key: e.key, locale: targetLocale, message: 'Failed to translate');
      }
      progress.step();
    }

    final finalProgress = ref.read(translationProgressProvider);
    logInfo('Batch translation completed: processed ${finalProgress.done}/${finalProgress.total} items');
    progress.finish();
  }
}

final translationBatchExecutorProvider = Provider<TranslationBatchExecutor>(TranslationBatchExecutor.new);
