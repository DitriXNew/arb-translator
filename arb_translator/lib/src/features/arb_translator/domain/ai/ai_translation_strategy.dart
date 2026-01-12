/// Элемент для батчевого перевода
class BatchTranslationItem {
  const BatchTranslationItem({required this.key, required this.text, this.description});

  final String key;
  final String text;
  final String? description;
}

abstract class AiTranslationStrategy {
  /// Перевод одной строки (legacy метод для совместимости)
  Future<String> translate({
    required String apiKey,
    required String englishText,
    required String targetLocale,
    String? description,
    String? glossaryPrompt,
  });

  /// Батчевый перевод нескольких строк с использованием structured output
  /// Возвращает Map<key, translation>
  Future<Map<String, String>> translateBatch({
    required String apiKey,
    required List<BatchTranslationItem> items,
    required String targetLocale,
    String? glossaryPrompt,
  });

  String get id;
  String get label;
}
