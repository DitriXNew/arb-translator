/// Item for batch translation
class BatchTranslationItem {
  const BatchTranslationItem({required this.key, required this.text, this.description});

  final String key;
  final String text;
  final String? description;
}

abstract class AiTranslationStrategy {
  /// Translate a single string (legacy method for compatibility)
  Future<String> translate({
    required String apiKey,
    required String englishText,
    required String targetLocale,
    String? description,
    String? glossaryPrompt,
  });

  /// Batch translation of multiple strings using structured output
  /// Returns `Map<key, translation>`
  Future<Map<String, String>> translateBatch({
    required String apiKey,
    required List<BatchTranslationItem> items,
    required String targetLocale,
    String? glossaryPrompt,
  });

  String get id;
  String get label;
}
