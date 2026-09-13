import 'dart:convert';
import 'dart:io';

import 'package:arb_translator/src/features/arb_translator/data/datasources/arb_file_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

/// Round-trips the real ai_video_translator template, which is what this tool
/// actually damaged: a sync stripped 127 placeholder attributes across 54 keys
/// and took the template's typed placeholders from 89 to 0.
///
/// Skipped when that checkout is not present, so the suite still runs alone.
void main() {
  const templatePath = r'd:/Flutter/translator/translator/lib/core/l10n/arb/app_en.arb';

  test('real template keeps every placeholder attribute through load -> save', () {
    final file = File(templatePath);
    if (!file.existsSync()) {
      markTestSkipped('template not present at $templatePath');
      return;
    }

    final source = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final ds = ArbFileDataSource();
    final (_, entries) = ds.merge(<String, Map<String, dynamic>>{'en': source});
    final out = ds.serializeLocale(entries: entries, locale: 'en', baseLocale: 'en');

    Map<String, Map<String, dynamic>> placeholdersOf(Map<String, dynamic> arb) {
      final result = <String, Map<String, dynamic>>{};
      for (final entry in arb.entries) {
        if (!entry.key.startsWith('@') || entry.key.startsWith('@@')) continue;
        final meta = entry.value;
        if (meta is! Map) continue;
        final placeholders = meta['placeholders'];
        if (placeholders is! Map) continue;
        for (final placeholder in placeholders.entries) {
          result['${entry.key}.${placeholder.key}'] = placeholder.value is Map
              ? Map<String, dynamic>.from(placeholder.value as Map)
              : <String, dynamic>{};
        }
      }
      return result;
    }

    final before = placeholdersOf(source);
    final after = placeholdersOf(out);

    expect(after.keys.toSet(), before.keys.toSet(), reason: 'no placeholder may be dropped or invented');
    for (final name in before.keys) {
      expect(after[name], before[name], reason: 'attributes of $name must round-trip verbatim');
    }

    final typed = before.values.where((a) => a.containsKey('type')).length;
    expect(typed, greaterThan(0), reason: 'template is expected to declare typed placeholders');
    expect(
      after.values.where((a) => a.containsKey('type')).length,
      typed,
      reason: 'typed placeholder count must not drop',
    );
  });
}
