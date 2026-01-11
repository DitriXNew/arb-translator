import 'dart:convert';
import 'dart:io';

import 'package:arb_translator/src/core/services/log_service.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/entry_metadata.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';

/// Low-level ARB file read/write utilities.
class ArbFileDataSource {
  static const arbExtension = '.arb';

  Future<List<File>> listArbFiles(String folderPath) async {
    logDebug('Listing ARB files in folder: $folderPath');

    final dir = Directory(folderPath);
    if (!dir.existsSync()) {
      logWarning('Directory does not exist: $folderPath');
      return [];
    }

    final files = <File>[];
    await for (final entity in dir.list()) {
      if (entity is File && entity.path.toLowerCase().endsWith(arbExtension)) {
        files.add(entity);
      }
    }

    logInfo('Found ${files.length} ARB files in $folderPath');
    return files;
  }

  Future<Map<String, dynamic>> readArb(File file) async {
    logDebug('Reading ARB file: ${file.path}');

    final content = await file.readAsString();
    final data = json.decode(content) as Map<String, dynamic>;

    logDebug('Successfully read ARB file: ${file.path}, keys: ${data.keys.length}');
    return data;
  }

  Future<void> writeArb({
    required String folderPath,
    required String locale,
    required Map<String, dynamic> data,
  }) async {
    final file = File(_localeFilePath(folderPath, locale));
    logDebug('Writing ARB file: ${file.path}, keys: ${data.keys.length}');

    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(data));

    logInfo('Successfully wrote ARB file: ${file.path}');
  }

  String _localeFilePath(String folder, String locale) => '$folder/app_$locale.arb';

  /// Merge ARB maps into TranslationEntry list.
  (List<String> locales, List<TranslationEntry> entries) merge(Map<String, Map<String, dynamic>> perLocale) {
    final locales = perLocale.keys.toList()..sort();
    const baseLocale = 'en';
    if (!locales.contains(baseLocale)) {
      locales.insert(0, baseLocale); // enforce presence/order (will show empty)
    } else {
      // move en after key/desc/placeholders (UI will handle columns)
      locales.remove(baseLocale);
      locales.insert(0, baseLocale);
    }

    final allKeys = <String>{};
    for (final l in locales) {
      allKeys.addAll(perLocale[l]?.keys.where((k) => !k.startsWith('@')) ?? const {});
    }
    final entries = <TranslationEntry>[];
    for (final key in allKeys.toList()..sort()) {
      // metadata from English @key
      final enMap = perLocale[baseLocale] ?? const {};
      final metaMap = enMap['@$key'] as Map<String, dynamic>?;

      EntryMetadata meta;
      if (metaMap != null) {
        final placeholdersRaw = metaMap['placeholders'];
        final placeholders = placeholdersRaw is Map ? Set<String>.from(placeholdersRaw.keys) : const <String>{};
        final storedHash = metaMap['sourceHash'] as String?;
        meta = EntryMetadata(
          description: metaMap['description'] as String?,
          placeholders: placeholders,
          sourceHash: storedHash,
        );
      } else {
        meta = const EntryMetadata();
      }
      final values = <String, String>{};
      for (final l in locales) {
        final v = perLocale[l]?[key];
        values[l] = v is String ? v : '';
      }
      entries.add(TranslationEntry(key: key, meta: meta, values: values));
    }
    return (locales, entries);
  }

  /// Serialize entries for one locale respecting rules.
  Map<String, dynamic> serializeLocale({
    required List<TranslationEntry> entries,
    required String locale,
    required String baseLocale,
  }) {
    // Desired ordering:
    // 1. @@locale first
    // 2. For each translation key in alphabetical order: the key, then (only in base locale)
    //    its metadata entry @key immediately after it. This keeps key+meta paired for readability
    //    and stable diffs, instead of default pure alphabetical where '@key' would sort before
    //    normal keys due to the '@' prefix.
    final map = <String, dynamic>{'@@locale': locale};
    final sorted = [...entries]..sort((a, b) => a.key.compareTo(b.key));
    for (final e in sorted) {
      // Add the translation value first
      map[e.key] = e.values[locale] ?? '';
      // Only base locale file carries metadata directly after its key
      if (locale == baseLocale) {
        final hasDescription = (e.meta.description ?? '').isNotEmpty;
        final hasPlaceholders = e.meta.placeholders.isNotEmpty;
        final hasSourceHash = (e.meta.sourceHash ?? '').isNotEmpty;
        if (hasDescription || hasPlaceholders || hasSourceHash) {
          map['@${e.key}'] = {
            if (hasDescription) 'description': e.meta.description,
            if (hasPlaceholders) 'placeholders': {for (final p in e.meta.placeholders) p: <String, dynamic>{}},
            if (hasSourceHash) 'sourceHash': e.meta.sourceHash,
          };
        }
      }
    }
    // Insertion order of LinkedHashMap (default) preserves our custom ordering.
    return map;
  }
}
