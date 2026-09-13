import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:arb_translator/src/features/arb_translator/data/datasources/arb_file_datasource.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/entry_metadata.dart';

void main() {
  group('ArbFileDataSource merge & serialize', () {
    final ds = ArbFileDataSource();

    test('merge creates entries with metadata only from base locale', () {
      final perLocale = <String, Map<String, dynamic>>{
        'en': {
          '@@locale': 'en',
          'hello': 'Hello {name}',
          '@hello': {
            'description': 'Greeting',
            'placeholders': <String, dynamic>{'name': <String, dynamic>{}},
          },
          'bye': 'Bye',
        },
        'de': {'@@locale': 'de', 'hello': 'Hallo {name}'},
      };
      final (locales, entries) = ds.merge(perLocale);
      expect(locales, ['en', 'de']);
      final hello = entries.firstWhere((e) => e.key == 'hello');
      expect(hello.meta.description, 'Greeting');
      expect(hello.meta.placeholders, {'name': <String, dynamic>{}});
      final bye = entries.firstWhere((e) => e.key == 'bye');
      expect(bye.meta.description, isNull);
    });

    test('serializeLocale base includes metadata, others exclude', () {
      final entries = [
        const TranslationEntry(
          key: 'hello',
          meta: EntryMetadata(description: 'Greeting', placeholders: {'name': <String, dynamic>{}}),
          values: {'en': 'Hello {name}', 'de': 'Hallo {name}'},
        ),
        const TranslationEntry(key: 'bye', values: {'en': 'Bye', 'de': 'Tschüss'}),
      ];
      final enMap = ds.serializeLocale(entries: entries, locale: 'en', baseLocale: 'en');
      final deMap = ds.serializeLocale(entries: entries, locale: 'de', baseLocale: 'en');
      expect(enMap.containsKey('@hello'), isTrue);
      // A non-base locale carries the source hash — that is what lets a stale
      // translation be detected without the English file — but none of the
      // descriptive metadata, which lives in the base locale alone.
      expect((deMap['@hello'] as Map).keys, ['sourceHash']);
      expect(enMap.keys.first, '@@locale');
      // New ordering rule: keys alphabetically, each key followed immediately by its metadata (@key) in base locale.
      final keys = enMap.keys.toList();
      // `bye` carries no description or placeholders and still gets an @bye
      // block, because every base-locale key is given a source hash.
      expect(keys, ['@@locale', 'bye', '@bye', 'hello', '@hello']);
      // Assert @hello directly follows hello
      final helloIndex = keys.indexOf('hello');
      expect(keys[helloIndex + 1], '@hello');
    });

    test('writeArb produces file with sorted keys and preserves @@locale first', () async {
      final tempDir = await Directory.systemTemp.createTemp('arb_test');
      final ordered = ds.serializeLocale(
        entries: [
          const TranslationEntry(key: 'a', values: {'en': '1'}),
          const TranslationEntry(key: 'b', values: {'en': '2'}),
        ],
        locale: 'en',
        baseLocale: 'en',
      );
      await ds.writeArb(folderPath: tempDir.path, locale: 'en', fileNamePrefix: 'app_', data: ordered);
      final file = File(p.join(tempDir.path, 'app_en.arb'));
      final content = await file.readAsString();
      final decoded = json.decode(content) as Map<String, dynamic>;
      final keys = decoded.keys.toList();
      expect(keys.first, '@@locale');
      // Each base-locale key is followed immediately by its own @key block, which
      // is emitted even with no description or placeholders because it carries
      // the source hash.
      expect(keys, ['@@locale', 'a', '@a', 'b', '@b']);
      await tempDir.delete(recursive: true);
    });
  });
}
