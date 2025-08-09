import 'dart:async';

import 'package:arb_translator/src/features/arb_translator/domain/ai/ai_strategy_ids.dart';
import 'package:arb_translator/src/features/arb_translator/domain/ai/ai_translation_strategy.dart';

/// Lightweight mock strategy useful for tests / offline demos.
/// Simply returns the english text annotated with target locale.
class MockTranslationStrategy implements AiTranslationStrategy {
  const MockTranslationStrategy();

  @override
  String get id => AiStrategyIds.mock;

  @override
  String get label => 'Mock';

  @override
  Future<String> translate({
    required String apiKey,
    required String englishText,
    required String targetLocale,
    String? description,
    String? glossaryPrompt,
  }) async {
    // Simulate slight latency to mimic network behaviour in UI tests.
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return '$englishText<$targetLocale>';
  }
}
