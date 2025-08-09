abstract class AiTranslationStrategy {
  Future<String> translate({
    required String apiKey,
    required String englishText,
    required String targetLocale,
    String? description,
    String? glossaryPrompt,
  });
  String get id;
  String get label;
}
