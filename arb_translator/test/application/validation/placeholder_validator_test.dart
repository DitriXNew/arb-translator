import 'package:flutter_test/flutter_test.dart';
import 'package:arb_translator/src/features/arb_translator/application/validation/placeholder_validator.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/entry_metadata.dart';

void main() {
  group('PlaceholderValidator', () {
    final validator = const PlaceholderValidator();
    const base = 'en';

    TranslationEntry entry({required String en, String fr = ''}) =>
        TranslationEntry(
          key: 'greet',
          meta: const EntryMetadata(),
          values: {base: en, if (fr.isNotEmpty) 'fr': fr},
        );

    test('detects mismatch', () {
      final e = entry(en: 'Hello {name}', fr: 'Bonjour {nom}');
      final errors = validator.validateCell(
        entry: e,
        locale: 'fr',
        baseLocale: base,
        allEntries: [e],
        previousErrors: {},
      );
      expect(errors.contains(('greet', 'fr')), isTrue);
    });

    test('clears error after fix', () {
      final e1 = entry(en: 'Hello {name}', fr: 'Bonjour {nom}');
      final withError = validator.validateCell(
        entry: e1,
        locale: 'fr',
        baseLocale: base,
        allEntries: [e1],
        previousErrors: {},
      );
      final e2 = entry(en: 'Hello {name}', fr: 'Bonjour {name}');
      final cleared = validator.validateCell(
        entry: e2,
        locale: 'fr',
        baseLocale: base,
        allEntries: [e2],
        previousErrors: withError,
      );
      expect(cleared.contains(('greet', 'fr')), isFalse);
    });

    test('revalidates all locales when base locale changed', () {
      final e1 = const TranslationEntry(
        key: 'phrase',
        values: {base: 'Hi {name}', 'fr': 'Salut {name}'},
      );
      final errs1 = validator.validateCell(
        entry: e1,
        locale: 'fr',
        baseLocale: base,
        allEntries: [e1],
        previousErrors: {},
      );
      expect(errs1, isEmpty);
      // Change base locale placeholders -> now mismatch
      final e2 = const TranslationEntry(
        key: 'phrase',
        values: {base: 'Hi {firstName}', 'fr': 'Salut {name}'},
      );
      final errs2 = validator.validateCell(
        entry: e2,
        locale: base, // indicate base changed
        baseLocale: base,
        allEntries: [e2],
        previousErrors: errs1,
      );
      expect(errs2.contains(('phrase', 'fr')), isTrue);
    });
  });
}
