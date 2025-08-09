/// Builds AI translation prompts in a single place for consistency & testability.
class PromptBuilder {
  const PromptBuilder();

  String buildTranslationPrompt({
    required String englishText,
    required String targetLocale,
    String? description,
    String? glossary,
  }) {
    final sb = StringBuffer();
    sb.writeln('Translate the following text to $targetLocale.');
    sb.writeln('Preserve placeholders like {name} unchanged (do NOT translate identifiers inside braces).');
    sb.writeln('Return plain text only, no surrounding quotes, no extra commentary.');
    sb.writeln('If source already fits target, still output a properly localized variant.');
    if (description != null && description.trim().isNotEmpty) {
      sb.writeln('Context: ${description.trim()}');
    }
    if (glossary != null && glossary.trim().isNotEmpty) {
      sb.writeln('Glossary / Terminology (preserve term casing, do not invent new terms):');
      sb.writeln(glossary.trim());
    }
    sb.writeln('Text:');
    sb.write(englishText);
    return sb.toString();
  }
}
