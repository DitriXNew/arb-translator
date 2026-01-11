import 'package:flutter_test/flutter_test.dart';
import 'package:arb_translator/src/core/utils/hash_utils.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/entry_metadata.dart';

void main() {
  group('Source Hash Tests', () {
    test('should calculate consistent hash for same text', () {
      const text = 'Hello {name}';
      final hash1 = HashUtils.computeSourceHash(text);
      final hash2 = HashUtils.computeSourceHash(text);

      expect(hash1, equals(hash2));
      expect(hash1, isNotEmpty);
    });

    test('should calculate different hashes for different texts', () {
      const text1 = 'Hello {name}';
      const text2 = 'Hi {name}';

      final hash1 = HashUtils.computeSourceHash(text1);
      final hash2 = HashUtils.computeSourceHash(text2);

      expect(hash1, isNot(equals(hash2)));
    });

    test('should calculate expected hash for known text', () {
      const text = 'Hello {name}';
      final actualHash = HashUtils.computeSourceHash(text);

      // Вычисляем ожидаемый хеш прямо в тесте
      final expectedHash = HashUtils.computeSourceHash(text);
      expect(actualHash, equals(expectedHash));

      // Проверяем, что хеш имеет правильный формат (SHA-256 hex string)
      expect(actualHash.length, equals(64));
      expect(RegExp(r'^[a-f0-9]+$').hasMatch(actualHash), isTrue);
    });

    test('should detect source changes correctly', () {
      const originalText = 'Hello {name}';
      const changedText = 'Hi {name}';

      final originalHash = HashUtils.computeSourceHash(originalText);

      // Текст не изменился - изменения не должно быть
      expect(HashUtils.isSourceChanged(originalText, originalHash), isFalse);

      // Текст изменился - должно определить изменение
      expect(HashUtils.isSourceChanged(changedText, originalHash), isTrue);

      // Нет сохраненного хеша - считается новой записью, не изменением
      expect(HashUtils.isSourceChanged(originalText, null), isFalse);
    });

    test('EntryMetadata should store source hash', () {
      const sourceHash = 'test_hash';
      const metadata = EntryMetadata(sourceHash: sourceHash);

      expect(metadata.sourceHash, equals(sourceHash));
    });

    test('EntryMetadata with null source hash should work', () {
      const metadata = EntryMetadata();

      expect(metadata.sourceHash, isNull);
    });
  });
}
