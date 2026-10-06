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
    required Set<(String, String)> previousErrors,
  }) {
    final english = entry.values[baseLocale] ?? '';
    final englishPlaceholders = extractPlaceholdersFromText(english);
    final newErrors = Set<(String, String)>.from(previousErrors);

    void check(String l) {
      final target = entry.values[l] ?? '';
      final valid =
          placeholdersMatch(english: englishPlaceholders, target: extractPlaceholdersFromText(target)) &&
          hasBalancedBraces(target);
      if (valid) {
        newErrors.remove((entry.key, l));
      } else {
        newErrors.add((entry.key, l));
      }
    }

    if (locale == baseLocale) {
      // A base edit revalidates every locale of this key.
      entry.values.keys.where((l) => l != baseLocale).forEach(check);
    } else {
      check(locale);
    }
    return newErrors;
  }
}
