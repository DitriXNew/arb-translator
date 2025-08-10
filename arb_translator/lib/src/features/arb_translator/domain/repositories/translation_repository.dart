import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';

/// Contract for reading/writing ARB data.
abstract class TranslationRepository {
  /// Load all .arb files in [folderPath].
  /// Returns (baseLocale, locales, entries).
  Future<(String baseLocale, List<String> locales, List<TranslationEntry> entries)> loadFolder(String folderPath);

  /// Persist current entries to disk across all locales.
  Future<void> saveAll({
    required String folderPath,
    required String baseLocale,
    required List<String> locales,
    required List<TranslationEntry> entries,
  });
}
