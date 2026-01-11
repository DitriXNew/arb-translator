import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:arb_translator/src/core/utils/hash_utils.dart';
import 'package:arb_translator/src/features/arb_translator/data/datasources/arb_file_datasource.dart';
import 'package:arb_translator/src/features/arb_translator/data/repositories/translation_repository_impl.dart';
import 'package:arb_translator/src/features/arb_translator/domain/usecases/load_arb_folder.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_controller.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Source Hash Tracking Integration', () {
    late Directory tempDir;
    late ArbFileDataSource ds;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('arb_hash_test');
      // Initial English ARB with sourceHash
      // Правильный хеш для "Welcome to our app"
      final correctHash = HashUtils.computeSourceHash("Welcome to our app");

      await File(p.join(tempDir.path, 'app_en.arb')).writeAsString('''{
  "@@locale": "en",
  "hello": "Hello {name}",
  "@hello": {
    "description": "Greet user", 
    "placeholders": {"name": {}},
    "sourceHash": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  },
  "welcome": "Welcome to our app",
  "@welcome": {
    "description": "Welcome message",
    "sourceHash": "$correctHash"
  }
}''');
      // German translation
      await File(p.join(tempDir.path, 'app_de.arb')).writeAsString('''{
  "@@locale": "de",
  "hello": "Hallo {name}",
  "welcome": "Willkommen in unserer App"
}''');
      ds = ArbFileDataSource();
    });

    tearDown(() async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    test('detects source changes based on hash comparison', () async {
      final repo = TranslationRepositoryImpl(ds);
      final loader = LoadArbFolder(repo);

      // Load project
      final (baseLocale, locales, entries) = await loader(tempDir.path);
      expect(baseLocale, 'en');
      expect(locales, ['en', 'de']);
      expect(entries.length, 2);

      // Create controller and load
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(projectControllerProvider.notifier);

      await controller.loadFolder(tempDir.path);
      final state = container.read(projectControllerProvider);

      // Should detect one source change (hello has wrong hash, welcome has no content to compare)
      expect(state.sourceChangedKeys.length, 1);
      expect(state.sourceChangedKeys.contains('hello'), isTrue);

      // Verify entry metadata
      final helloEntry = entries.firstWhere((e) => e.key == 'hello');
      expect(helloEntry.meta.sourceHash, isNotNull);
      expect(helloEntry.meta.sourceHash, isNotEmpty);
    });

    test('commitSourceHashes updates all hashes and clears changed keys', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(projectControllerProvider.notifier);

      await controller.loadFolder(tempDir.path);
      var state = container.read(projectControllerProvider);

      // Should have source changed keys
      expect(state.sourceChangedKeys.isNotEmpty, isTrue);

      // Commit source hashes
      controller.commitSourceHashes();
      state = container.read(projectControllerProvider);

      // Should clear all source changed keys
      expect(state.sourceChangedKeys.isEmpty, isTrue);
      expect(state.hasUnsavedChanges, isTrue);

      // All entries should have updated hashes
      for (final entry in state.entries) {
        final sourceText = entry.values[state.baseLocale] ?? '';
        if (sourceText.isNotEmpty) {
          expect(entry.meta.sourceHash, isNotNull);
          expect(entry.meta.sourceHash, isNotEmpty);
        }
      }
    });

    test('saves and loads source hashes correctly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(projectControllerProvider.notifier);

      // Load, commit hashes, and save
      await controller.loadFolder(tempDir.path);
      controller.commitSourceHashes();
      await controller.saveAll();

      // Read back the saved file
      final savedContent = await File(p.join(tempDir.path, 'app_en.arb')).readAsString();
      final savedData = json.decode(savedContent) as Map<String, dynamic>;

      // Should contain sourceHash in metadata
      expect(savedData['@hello'], isNotNull);
      expect(savedData['@hello']['sourceHash'], isNotNull);
      expect(savedData['@welcome'], isNotNull);
      expect(savedData['@welcome']['sourceHash'], isNotNull);

      // Load again and verify no source changes detected
      final container2 = ProviderContainer();
      addTearDown(container2.dispose);
      final controller2 = container2.read(projectControllerProvider.notifier);

      await controller2.loadFolder(tempDir.path);
      final state2 = container2.read(projectControllerProvider);

      // Should have no source changed keys since hashes are up to date
      expect(state2.sourceChangedKeys.isEmpty, isTrue);
    });

    test('handles new entries without source hashes', () async {
      // Create a file without any sourceHash metadata
      await File(p.join(tempDir.path, 'app_en.arb')).writeAsString('''{
  "@@locale": "en",
  "new_key": "New content without hash",
  "@new_key": {"description": "New entry"}
}''');

      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(projectControllerProvider.notifier);

      await controller.loadFolder(tempDir.path);
      final state = container.read(projectControllerProvider);

      // New entries without hashes should not be marked as changed
      expect(state.sourceChangedKeys.isEmpty, isTrue);

      final entry = state.entries.first;
      expect(entry.meta.sourceHash, isNull);
    });
  });
}
