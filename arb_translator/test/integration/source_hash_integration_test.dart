import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:arb_translator/src/features/arb_translator/data/datasources/arb_file_datasource.dart';
import 'package:arb_translator/src/features/arb_translator/data/repositories/translation_repository_impl.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';
import 'package:arb_translator/src/features/arb_translator/domain/usecases/load_arb_folder.dart';
import 'package:arb_translator/src/core/utils/hash_utils.dart';

void main() {
  group('Source Hash Integration Tests', () {
    late Directory tempDir;
    late TranslationRepositoryImpl repository;
    late ArbFileDataSource dataSource;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('arb_translator_test_');
      repository = TranslationRepositoryImpl(ArbFileDataSource());
      dataSource = ArbFileDataSource();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('should detect source changes when hash differs', () async {
      // Создаем файл с хешем для старого текста
      final oldText = 'Hello {name}';
      final oldHash = HashUtils.computeSourceHash(oldText);

      final enFile = File('${tempDir.path}/app_en.arb');
      await enFile.writeAsString('''
{
  "@@locale": "en",
  "greeting": "Hi {name}",
  "@greeting": {
    "description": "A greeting message",
    "placeholders": {
      "name": {
        "type": "String"
      }
    },
    "sourceHash": "$oldHash"
  }
}
''');

      final ruFile = File('${tempDir.path}/app_ru.arb');
      await ruFile.writeAsString('''
{
  "@@locale": "ru",
  "greeting": "Привет {name}"
}
''');

      // Загружаем данные
      final loader = LoadArbFolder(repository);
      final (baseLocale, locales, entries) = await loader(tempDir.path);
      expect(entries, hasLength(1));

      final entry = entries.first;
      expect(entry.key, equals('greeting'));
      expect(entry.values[baseLocale], equals('Hi {name}'));

      // Проверяем, что хеш отличается от сохраненного
      final currentHash = HashUtils.computeSourceHash(entry.values[baseLocale] ?? '');
      expect(entry.meta.sourceHash, equals(oldHash));
      expect(currentHash, isNot(equals(oldHash)));
    });

    test('should save updated hashes when committing', () async {
      // Создаем файл без хешей
      final enFile = File('${tempDir.path}/app_en.arb');
      await enFile.writeAsString('''
{
  "@@locale": "en",
  "greeting": "Hello {name}",
  "@greeting": {
    "description": "A greeting message",
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  },
  "farewell": "Goodbye {name}",
  "@farewell": {
    "description": "A farewell message",
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}
''');

      final ruFile = File('${tempDir.path}/app_ru.arb');
      await ruFile.writeAsString('''
{
  "@@locale": "ru",
  "greeting": "Привет {name}",
  "farewell": "До свидания {name}"
}
''');

      // Загружаем данные
      final loader = LoadArbFolder(repository);
      final (baseLocale, locales, entries) = await loader(tempDir.path);
      expect(entries, hasLength(2));

      // Обновляем хеши для всех записей
      final updatedEntries = entries.map((entry) {
        final sourceText = entry.values[baseLocale] ?? '';
        if (sourceText.isNotEmpty) {
          final newHash = HashUtils.computeSourceHash(sourceText);
          return entry.copyWith(meta: entry.meta.copyWith(sourceHash: newHash));
        }
        return entry;
      }).toList();

      // Сохраняем обновленные данные
      for (final locale in locales) {
        final data = dataSource.serializeLocale(entries: updatedEntries, locale: locale, baseLocale: baseLocale);
        await dataSource.writeArb(folderPath: tempDir.path, locale: locale, data: data);
      }

      // Перезагружаем и проверяем, что хеши сохранились
      final (_, _, reloadedEntries) = await loader(tempDir.path);
      expect(reloadedEntries, hasLength(2));

      for (final entry in reloadedEntries) {
        expect(entry.meta.sourceHash, isNotNull);
        final sourceText = entry.values[baseLocale] ?? '';
        final expectedHash = HashUtils.computeSourceHash(sourceText);
        expect(entry.meta.sourceHash, equals(expectedHash));
      }
    });

    test('should preserve existing metadata when adding source hash', () async {
      // Создаем файл с существующими метаданными
      final enFile = File('${tempDir.path}/app_en.arb');
      await enFile.writeAsString('''
{
  "@@locale": "en",
  "greeting": "Hello {name}",
  "@greeting": {
    "description": "A greeting message",
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}
''');

      // Загружаем данные
      final loader = LoadArbFolder(repository);
      final (baseLocale, locales, entries) = await loader(tempDir.path);
      expect(entries, hasLength(1));

      final entry = entries.first;

      // Добавляем хеш
      final sourceText = entry.values[baseLocale] ?? '';
      final newHash = HashUtils.computeSourceHash(sourceText);
      final updatedEntry = entry.copyWith(meta: entry.meta.copyWith(sourceHash: newHash));

      // Сохраняем
      for (final locale in locales) {
        final entries = [updatedEntry];
        final data = dataSource.serializeLocale(entries: entries, locale: locale, baseLocale: baseLocale);
        await dataSource.writeArb(folderPath: tempDir.path, locale: locale, data: data);
      }

      // Проверяем, что стандартные метаданные сохранились
      final content = await enFile.readAsString();
      expect(content, contains('"description": "A greeting message"'));
      expect(content, contains('"placeholders":'));
      expect(content, contains('"sourceHash": "$newHash"'));
    });
  });
}
