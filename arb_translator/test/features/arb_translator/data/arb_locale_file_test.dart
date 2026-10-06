import 'dart:convert';
import 'dart:io';

import 'package:arb_translator/src/features/arb_translator/data/datasources/arb_locale_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('arb_locale_file_test'));
  tearDown(() => dir.deleteSync(recursive: true));

  List<String> keysAfter(Map<String, dynamic> source, void Function(ArbLocaleFile file) edit) {
    final file = File(p.join(dir.path, 'app_de.arb'))..writeAsStringSync(json.encode(source));
    final arb = ArbLocaleFile.open(file, locale: 'de');
    edit(arb);
    return (json.decode(arb.encode()) as Map<String, dynamic>).keys.toList();
  }

  test('updating an existing key keeps every key where it was, metadata first or not', () {
    final keys = keysAfter({
      '@@locale': 'de',
      '@zeta': {'sourceHash': 'old'},
      'alpha': 'A',
      'zeta': 'Z',
    }, (f) => f.setTranslation('zeta', 'Zett', sourceHash: 'new'));

    expect(keys, ['@@locale', '@zeta', 'alpha', 'zeta']);
  });

  test('a new key goes into its sorted place with its metadata right after it', () {
    final keys = keysAfter({
      '@@locale': 'de',
      'alpha': 'A',
      'zeta': 'Z',
    }, (f) => f.setTranslation('mid', 'M', sourceHash: 'h'));

    expect(keys, ['@@locale', 'alpha', 'mid', '@mid', 'zeta']);
  });

  test('metadata added to an existing key goes right after it', () {
    final keys = keysAfter({
      '@@locale': 'de',
      'alpha': 'A',
      'zeta': 'Z',
    }, (f) => f.setTranslation('alpha', 'Ah', sourceHash: 'h'));

    expect(keys, ['@@locale', 'alpha', '@alpha', 'zeta']);
  });
}
