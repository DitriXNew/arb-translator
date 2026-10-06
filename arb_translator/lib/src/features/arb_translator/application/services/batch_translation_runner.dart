import 'package:arb_translator/src/features/arb_translator/domain/ai/ai_translation_strategy.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';

/// Batch size for translation
const int kTranslationBatchSize = 100;

/// Sends candidate entries to an [AiTranslationStrategy] in batches.
///
/// Holds no state of its own: results and failures go to the callbacks, so the desktop
/// UI applies them through its controller and the command line applies them to plain
/// entries. A failed batch is reported and the run continues with the next one.
class BatchTranslationRunner {
  const BatchTranslationRunner({
    required this.strategy,
    required this.apiKey,
    this.glossaryPrompt,
    this.batchSize = kTranslationBatchSize,
  });

  final AiTranslationStrategy strategy;
  final String apiKey;
  final String? glossaryPrompt;
  final int batchSize;

  /// Translates the base text of [candidates] into [targetLocale].
  ///
  /// [isCancelled] is checked before each batch; the batch in flight always completes.
  /// Returns the number of candidates whose batch was attempted.
  Future<int> run({
    required List<TranslationEntry> candidates,
    required String baseLocale,
    required String targetLocale,
    required void Function(List<TranslationEntry> batch, Map<String, String> translations) onBatchTranslated,
    required void Function(List<TranslationEntry> batch, Object error, StackTrace stackTrace) onBatchFailed,
    bool Function()? isCancelled,
  }) async {
    var processed = 0;
    for (var start = 0; start < candidates.length; start += batchSize) {
      if (isCancelled?.call() ?? false) break;
      final batch = candidates.sublist(start, (start + batchSize).clamp(0, candidates.length));
      try {
        final translations = await strategy.translateBatch(
          apiKey: apiKey,
          items: [
            for (final e in batch)
              BatchTranslationItem(key: e.key, text: e.values[baseLocale] ?? '', description: e.meta.description),
          ],
          targetLocale: targetLocale,
          glossaryPrompt: glossaryPrompt,
        );
        onBatchTranslated(batch, translations);
      } on Object catch (error, stackTrace) {
        onBatchFailed(batch, error, stackTrace);
      }
      processed += batch.length;
    }
    return processed;
  }
}
