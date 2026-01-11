import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Utility class for computing hashes of source text for change tracking
class HashUtils {
  /// Compute SHA-256 hash of the source text
  /// This is used to detect changes in the base locale text
  static String computeSourceHash(String sourceText) {
    final bytes = utf8.encode(sourceText.trim());
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Check if the current source text matches the stored hash
  static bool isSourceChanged(String currentText, String? storedHash) {
    if (storedHash == null) {
      // No hash stored means this is a new entry
      return false;
    }

    final currentHash = computeSourceHash(currentText);
    return currentHash != storedHash;
  }
}
