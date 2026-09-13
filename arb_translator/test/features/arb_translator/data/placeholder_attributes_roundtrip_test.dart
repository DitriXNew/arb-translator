import 'package:arb_translator/src/features/arb_translator/data/datasources/arb_file_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

/// Placeholder attributes must survive load -> save untouched.
///
/// `gen-l10n` reads placeholder types from the template ARB only, so a lost
/// `type` silently turns a generated `int` parameter into `Object`, and a lost
/// `format` disables NumberFormat / DateFormat in every locale at once. Neither
/// shows up as a failing build: `Object` accepts `int`, so the damage reaches
/// users as unformatted numbers and dates rather than as a compile error.
void main() {
  group('placeholder attributes round-trip', () {
    final ds = ArbFileDataSource();

    Map<String, dynamic> roundTrip(Map<String, dynamic> placeholders) {
      final perLocale = <String, Map<String, dynamic>>{
        'en': <String, dynamic>{
          '@@locale': 'en',
          'msg': 'Value {a}',
          '@msg': <String, dynamic>{'description': 'A message', 'placeholders': placeholders},
        },
      };
      final (_, entries) = ds.merge(perLocale);
      final out = ds.serializeLocale(entries: entries, locale: 'en', baseLocale: 'en');
      return (out['@msg'] as Map<String, dynamic>)['placeholders'] as Map<String, dynamic>;
    }

    test('keeps type on every placeholder', () {
      final result = roundTrip(<String, dynamic>{
        'hours': <String, dynamic>{'type': 'int'},
        'minutes': <String, dynamic>{'type': 'int'},
      });

      expect(result, <String, dynamic>{
        'hours': <String, dynamic>{'type': 'int'},
        'minutes': <String, dynamic>{'type': 'int'},
      });
    });

    test('keeps format, example and optionalParameters', () {
      final placeholders = <String, dynamic>{
        'when': <String, dynamic>{'type': 'DateTime', 'format': 'yMMMd', 'example': '1 Jan 2026'},
        'amount': <String, dynamic>{
          'type': 'double',
          'format': 'currency',
          'optionalParameters': <String, dynamic>{'decimalDigits': 2, 'symbol': r'$'},
        },
      };

      expect(roundTrip(placeholders), placeholders);
    });

    test('a placeholder that genuinely has no attributes stays empty', () {
      final result = roundTrip(<String, dynamic>{'name': <String, dynamic>{}});

      expect(result, <String, dynamic>{'name': <String, dynamic>{}});
    });

    test('a placeholder written as a non-map does not crash the merge', () {
      // Hand-edited ARBs do appear in the wild; the reader must degrade to an
      // empty attribute map rather than throw on the whole file.
      final result = roundTrip(<String, dynamic>{'weird': 'not-a-map'});

      expect(result, <String, dynamic>{'weird': <String, dynamic>{}});
    });
  });
}
