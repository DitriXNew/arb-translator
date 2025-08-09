import 'package:arb_translator/src/core/utils/arb_utils.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';

class PlaceholderValidationResult {
  const PlaceholderValidationResult(this.errorCells);
  final Set<(String key, String locale)> errorCells;
}

class PlaceholderValidator {
  const PlaceholderValidator();

  /// Validate placeholders for a single updated cell.
  /// Returns updated error cell set.
  Set<(String, String)> validateCell({
    required TranslationEntry entry,
    required String locale,
    required String baseLocale,
    required List<TranslationEntry> allEntries,
    required Set<(String, String)> previousErrors,
  }) {
    final english = entry.values[baseLocale] ?? '';
    final englishPlaceholders = extractPlaceholdersFromText(english);
    final newErrors = Set<(String, String)>.from(previousErrors);

    if (locale == baseLocale) {
      // Revalidate all locales for this key
      for (final l
          in allEntries.firstWhere((e) => e.key == entry.key).values.keys) {
        if (l == baseLocale) continue;
      }
      // Iterate locales list from entry values
      for (final l in entry.values.keys) {
        if (l == baseLocale) continue;
        final target = entry.values[l] ?? '';
        final tPh = extractPlaceholdersFromText(target);
        if (placeholdersMatch(english: englishPlaceholders, target: tPh)) {
          newErrors.remove((entry.key, l));
        } else {
          newErrors.add((entry.key, l));
        }
      }
    } else {
      final target = entry.values[locale] ?? '';
      final tPh = extractPlaceholdersFromText(target);
      if (placeholdersMatch(english: englishPlaceholders, target: tPh)) {
        newErrors.remove((entry.key, locale));
      } else {
        newErrors.add((entry.key, locale));
      }
    }
    return newErrors;
  }
}
