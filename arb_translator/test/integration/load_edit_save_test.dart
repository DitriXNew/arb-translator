import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:arb_translator/src/features/arb_translator/data/datasources/arb_file_datasource.dart';
import 'package:arb_translator/src/features/arb_translator/data/repositories/translation_repository_impl.dart';
import 'package:arb_translator/src/features/arb_translator/domain/usecases/load_arb_folder.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_controller.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Integration-style test (filesystem) for: load -> edit -> save -> reload.
void main() {
  group('Integration load-edit-save-reload', () {
    late Directory tempDir;
    late ArbFileDataSource ds;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('arb_int');
      // seed English & German
      await File(p.join(tempDir.path, 'app_en.arb')).writeAsString('''{
  "@@locale": "en",
  "hello": "Hello {name}",
  "@hello": {"description": "Greet user", "placeholders": {"name": {}}},
  "bye": "Bye"
}''');
      await File(p.join(tempDir.path, 'app_de.arb')).writeAsString('''{
  "@@locale": "de",
  "hello": "Hallo {name}"
}''');
      ds = ArbFileDataSource();
    });

    tearDown(() async {
      // Ensure no file ops in-flight before deletion.
      await Future<void>.delayed(const Duration(milliseconds: 10));
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    test('cycle maintains metadata, adds new translation, placeholder validation ok', () async {
      final repo = TranslationRepositoryImpl(ds);
      final loader = LoadArbFolder(repo);
      final (baseLocale, locales, entries) = await loader(tempDir.path);
      expect(baseLocale, 'en');
      expect(locales, ['en', 'de']);
      // Controller with loaded state
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(projectControllerProvider.notifier);
      // Keep provider alive during async ops (auto-dispose otherwise after first await).
      final sub = container.listen(projectControllerProvider, (_, _) {});
      addTearDown(sub.close);
      controller.state = ProjectState(
        folderPath: tempDir.path,
        baseLocale: baseLocale,
        locales: locales,
        entries: entries,
      );
      // Edit: add German bye translation
      controller.updateCell(key: 'bye', locale: 'de', text: 'Tschüss');
      expect(controller.state.dirtyCells.contains(('bye', 'de')), isTrue);
      expect(controller.state.errorCells, isEmpty);
      // Save
      await controller.saveAll();
      expect(controller.state.hasUnsavedChanges, isFalse);
      // Reload
      final (base2, locales2, entries2) = await loader(tempDir.path);
      expect(locales2, ['en', 'de']);
      final bye = entries2.firstWhere((e) => e.key == 'bye');
      expect(bye.values['de'], 'Tschüss');
      // Metadata persisted only in en
      final enFile = await File(p.join(tempDir.path, 'app_en.arb')).readAsString();
      final deFile = await File(p.join(tempDir.path, 'app_de.arb')).readAsString();
      expect(enFile.contains('@hello'), isTrue);
      expect(deFile.contains('@hello'), isFalse);
      // Placeholder mismatch scenario: alter German with missing placeholder
      controller.updateCell(key: 'hello', locale: 'de', text: 'Hallo');
      expect(controller.state.errorCells.contains(('hello', 'de')), isTrue);
    });
  });
}
