import 'package:arb_translator/src/features/arb_translator/application/validation/placeholder_validator.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/entry_metadata.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const validator = PlaceholderValidator();

  TranslationEntry entryWith({required String en, String fr = '', String de = ''}) =>
      TranslationEntry(key: 'greet', meta: const EntryMetadata(), values: {'en': en, 'fr': fr, 'de': de});

  test('no placeholders -> no errors', () {
    final e = entryWith(en: 'Hello', fr: 'Bonjour', de: 'Hallo');
    final res = validator.validateCell(entry: e, locale: 'fr', baseLocale: 'en', allEntries: [e], previousErrors: {});
    expect(res.isEmpty, isTrue);
  });

  test('matching placeholders -> no error', () {
    final e = entryWith(en: 'Hello {name}', fr: 'Bonjour {name}');
    final res = validator.validateCell(entry: e, locale: 'fr', baseLocale: 'en', allEntries: [e], previousErrors: {});
    expect(res.isEmpty, isTrue);
  });

  test('extra placeholder -> error added', () {
    final e = entryWith(en: 'Hello {name}', fr: 'Bonjour {name} {x}');
    final res = validator.validateCell(entry: e, locale: 'fr', baseLocale: 'en', allEntries: [e], previousErrors: {});
    expect(res.contains(('greet', 'fr')), isTrue);
  });

  test('missing placeholder -> error added', () {
    final e = entryWith(en: 'Hello {name}', fr: 'Bonjour');
    final res = validator.validateCell(entry: e, locale: 'fr', baseLocale: 'en', allEntries: [e], previousErrors: {});
    expect(res.contains(('greet', 'fr')), isTrue);
  });

  test('editing English revalidates others', () {
    final e = entryWith(en: 'Hello {name}', fr: 'Bonjour {name}', de: 'Hallo {name}');
    final withErr = validator.validateCell(
      entry: e,
      locale: 'fr',
      baseLocale: 'en',
      allEntries: [e],
      previousErrors: {},
    );
    expect(withErr.isEmpty, isTrue);
    // Change English to introduce new placeholder {id}
    final e2 = entryWith(en: 'Hello {name} {id}', fr: 'Bonjour {name}', de: 'Hallo {name} {id}');
    final res = validator.validateCell(
      entry: e2,
      locale: 'en',
      baseLocale: 'en',
      allEntries: [e2],
      previousErrors: withErr,
    );
    expect(res.contains(('greet', 'fr')), isTrue); // fr now missing {id}
    expect(res.contains(('greet', 'de')), isFalse); // de matches
  });
}
