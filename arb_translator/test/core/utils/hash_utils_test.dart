import 'package:arb_translator/src/core/utils/hash_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HashUtils', () {
    test('computeSourceHash returns consistent hash for same text', () {
      const text = 'Hello world';
      final hash1 = HashUtils.computeSourceHash(text);
      final hash2 = HashUtils.computeSourceHash(text);

      expect(hash1, equals(hash2));
      expect(hash1, isNotEmpty);
    });

    test('computeSourceHash returns different hash for different text', () {
      const text1 = 'Hello world';
      const text2 = 'Hello universe';
      final hash1 = HashUtils.computeSourceHash(text1);
      final hash2 = HashUtils.computeSourceHash(text2);

      expect(hash1, isNot(equals(hash2)));
    });

    test('computeSourceHash handles empty text', () {
      final hash = HashUtils.computeSourceHash('');
      expect(hash, isNotEmpty);
    });

    test('computeSourceHash trims whitespace', () {
      const text = 'Hello world';
      final hash1 = HashUtils.computeSourceHash(text);
      final hash2 = HashUtils.computeSourceHash('  $text  ');

      expect(hash1, equals(hash2));
    });

    test('isSourceChanged returns false when no hash stored', () {
      const text = 'Hello world';
      expect(HashUtils.isSourceChanged(text, null), isFalse);
    });

    test('isSourceChanged returns false when hash matches', () {
      const text = 'Hello world';
      final hash = HashUtils.computeSourceHash(text);
      expect(HashUtils.isSourceChanged(text, hash), isFalse);
    });

    test('isSourceChanged returns true when hash differs', () {
      const text1 = 'Hello world';
      const text2 = 'Hello universe';
      final hash1 = HashUtils.computeSourceHash(text1);
      expect(HashUtils.isSourceChanged(text2, hash1), isTrue);
    });

    test('isSourceChanged handles empty hash', () {
      const text = 'Hello world';
      expect(HashUtils.isSourceChanged(text, ''), isTrue);
    });
  });
}
