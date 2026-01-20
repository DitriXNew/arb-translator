import 'dart:async';

import 'package:arb_translator/src/core/services/log_service.dart';
import 'package:arb_translator/src/features/arb_translator/domain/ai/ai_translation_strategy.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_errors_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_settings_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_strategy_registry.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/locale_translation_progress_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_controller.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/translation_progress_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Batch size for translation
const int kTranslationBatchSize = 100;

/// Encapsulates bulk AI translation logic with batch processing.
/// Uses structured output (JSON schema) for efficient translation of multiple strings.
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

    // Filter candidates for translation
    final candidates = <TranslationEntry>[
      for (final e in entries)
        if ((e.values[baseLocale] ?? '').isNotEmpty)
          if (!onlyEmpty || (e.values[targetLocale] ?? '').isEmpty) e,
    ];

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

    // Split into batches of kTranslationBatchSize
    final batches = <List<TranslationEntry>>[];
    for (var i = 0; i < candidates.length; i += kTranslationBatchSize) {
      batches.add(candidates.sublist(i, (i + kTranslationBatchSize).clamp(0, candidates.length)));
    }

    logInfo('Split into ${batches.length} batches of up to $kTranslationBatchSize items');

    var totalProcessed = 0;

    for (var batchIndex = 0; batchIndex < batches.length; batchIndex++) {
      // Check for cancellation
      final progressState = ref.read(localeTranslationProgressProvider);
      if (progressState.isCancelRequested(targetLocale)) {
        logInfo('Batch translation cancelled by user after batch $batchIndex');
        break;
      }

      final batch = batches[batchIndex];
      logDebug('Processing batch ${batchIndex + 1}/${batches.length} with ${batch.length} items');

      try {
        // Prepare items for batch
        final batchItems = batch
            .map(
              (e) =>
                  BatchTranslationItem(key: e.key, text: e.values[baseLocale] ?? '', description: e.meta.description),
            )
            .toList();

        // Execute batch translation
        final translations = await strategy.translateBatch(
          apiKey: apiKey,
          items: batchItems,
          targetLocale: targetLocale,
          glossaryPrompt: glossary,
        );

        // Apply translations
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

        totalProcessed += batch.length;
        localeProgress.updateProgress(targetLocale, totalProcessed);
        globalProgress.updateDone(totalProcessed);

        logDebug('Batch ${batchIndex + 1} completed: ${translations.length}/${batch.length} translations applied');
      } catch (ex, st) {
        logError('Batch ${batchIndex + 1} failed', ex, st);

        // Add errors for all batch items
        for (final entry in batch) {
          ref
              .read(aiErrorsProvider.notifier)
              .add(key: entry.key, locale: targetLocale, message: 'Batch translation failed: $ex');
        }

        // Update progress even on error
        totalProcessed += batch.length;
        localeProgress.updateProgress(targetLocale, totalProcessed);
        globalProgress.updateDone(totalProcessed);
      }
    }

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
