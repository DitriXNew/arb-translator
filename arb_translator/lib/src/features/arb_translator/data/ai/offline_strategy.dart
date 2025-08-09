import 'package:arb_translator/src/features/arb_translator/domain/ai/ai_strategy_ids.dart';
import 'package:arb_translator/src/features/arb_translator/domain/ai/ai_translation_strategy.dart';

/// Placeholder offline strategy. Currently returns the original text unchanged.
/// Intended future hook for a local model / rules based translator.
class OfflinePassthroughStrategy implements AiTranslationStrategy {
  const OfflinePassthroughStrategy();

  @override
  String get id => AiStrategyIds.offline;

  @override
  String get label => 'Offline';

  @override
  Future<String> translate({
    required String apiKey,
    required String englishText,
    required String targetLocale,
    String? description,
    String? glossaryPrompt,
  }) async => englishText;
}
