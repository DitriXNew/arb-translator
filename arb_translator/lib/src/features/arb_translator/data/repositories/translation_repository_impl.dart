import 'dart:io';

import 'package:arb_translator/src/features/arb_translator/data/datasources/arb_file_datasource.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';
import 'package:arb_translator/src/features/arb_translator/domain/repositories/translation_repository.dart';
import 'package:logger/logger.dart';

class TranslationRepositoryImpl implements TranslationRepository {
  TranslationRepositoryImpl(this.fileDs);
  final ArbFileDataSource fileDs;
  static final Logger _log = Logger();

  @override
  Future<(String baseLocale, List<String> locales, List<TranslationEntry> entries)> loadFolder(
    String folderPath,
  ) async {
    final files = await fileDs.listArbFiles(folderPath);
    _log.d(
      'TranslationRepositoryImpl.loadFolder: found \\${files.length} ARB files in $folderPath: '
      '\\${files.map((f) => f.path.split(Platform.pathSeparator).last).join(', ')}',
    );
    final perLocale = <String, Map<String, dynamic>>{};
    for (final f in files) {
      final map = await fileDs.readArb(f);
      final locale = (map['@@locale'] as String?) ?? _inferLocaleFromName(f);
      perLocale[locale] = map;
    }
    final (locales, entries) = fileDs.merge(perLocale);
    if (entries.isEmpty) {
      _log.w('Post-merge empty entries. Locales: ${locales.length}; perLocale keys: ${perLocale.keys.toList()}');
      for (final k in perLocale.keys) {
        _log.w('Locale $k keys: ${perLocale[k]?.keys.toList()}');
      }
    } else {
      _log.d('Post-merge produced ${entries.length} entries across ${locales.length} locales');
    }
    return ('en', locales, entries);
  }

  @override
  Future<void> saveAll({
    required String folderPath,
    required String baseLocale,
    required List<String> locales,
    required List<TranslationEntry> entries,
  }) async {
    for (final l in locales) {
      final map = fileDs.serializeLocale(entries: entries, locale: l, baseLocale: baseLocale);
      await fileDs.writeArb(folderPath: folderPath, locale: l, data: map);
    }
  }

  String _inferLocaleFromName(File f) {
    final name = f.uri.pathSegments.last; // app_en.arb
    final match = RegExp(r'app_(.*)\.arb').firstMatch(name);
    return match != null ? match.group(1)! : 'en';
  }
}
