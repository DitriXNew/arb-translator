import 'package:arb_translator/src/features/arb_translator/application/services/prompt_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PromptBuilder', () {
    const builder = PromptBuilder();
    test('includes glossary and description when provided', () {
      final prompt = builder.buildTranslationPrompt(
        englishText: 'Hello {name}',
        targetLocale: 'fr',
        description: 'Greeting to user',
        glossary: 'AppName => keep untranslated.',
      );
      expect(prompt, contains('Greeting to user'));
      expect(prompt, contains('Glossary'));
      expect(prompt, contains('AppName'));
      expect(prompt, contains('Hello {name}'));
    });

    test('omits empty description/glossary', () {
      final prompt = builder.buildTranslationPrompt(
        englishText: 'Hi',
        targetLocale: 'de',
        description: '   ',
        glossary: '',
      );
      expect(prompt.contains('Glossary'), isFalse);
      expect(prompt.contains('Context:'), isFalse);
    });
  });
}
