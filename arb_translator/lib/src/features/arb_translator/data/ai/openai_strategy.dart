import 'package:arb_translator/src/features/arb_translator/application/services/prompt_builder.dart';
import 'package:arb_translator/src/features/arb_translator/data/datasources/openai_remote_datasource.dart';
import 'package:arb_translator/src/features/arb_translator/domain/ai/ai_translation_strategy.dart';

class OpenAiTranslationStrategy implements AiTranslationStrategy {
  OpenAiTranslationStrategy(this._ds, {PromptBuilder? promptBuilder})
    : _promptBuilder = promptBuilder ?? const PromptBuilder();
  final OpenAiRemoteDataSource _ds;
  final PromptBuilder _promptBuilder;

  @override
  String get id => 'openai';

  @override
  String get label => 'OpenAI';

  @override
  Future<String> translate({
    required String apiKey,
    required String englishText,
    required String targetLocale,
    String? description,
    String? glossaryPrompt,
  }) {
    final prompt = _promptBuilder.buildTranslationPrompt(
      englishText: englishText,
      targetLocale: targetLocale,
      description: description,
      glossary: glossaryPrompt,
    );
    // Hard-coded model (gpt-4.1-mini) per current specification.
    return _ds.translate(apiKey: apiKey, prompt: prompt);
  }

  @override
  Future<Map<String, String>> translateBatch({
    required String apiKey,
    required List<BatchTranslationItem> items,
    required String targetLocale,
    String? glossaryPrompt,
  }) {
    // Конвертируем BatchTranslationItem в TranslationItem для datasource
    final dsItems = items
        .map((item) => TranslationItem(key: item.key, text: item.text, description: item.description))
        .toList();

    return _ds.translateBatch(
      apiKey: apiKey,
      items: dsItems,
      targetLocale: targetLocale,
      glossaryPrompt: glossaryPrompt,
    );
  }
}
