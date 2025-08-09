import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_controller.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_state.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/filtered_entries_provider.dart';
import 'package:arb_translator/src/features/arb_translator/data/datasources/arb_file_datasource.dart';
import 'package:arb_translator/src/features/arb_translator/data/repositories/translation_repository_impl.dart';
import 'package:arb_translator/src/features/arb_translator/domain/usecases/load_arb_folder.dart';

void main() {
  group('Rename / Delete / Combined filters integration', () {
    late ArbFileDataSource ds;

    setUp(() {
      ds = ArbFileDataSource();
    });

    Future<(ProviderContainer, ProjectController)> loadTemp(
      Map<String, String> files,
    ) async {
      final dir = await Directory.systemTemp.createTemp('arb_cases');
      for (final entry in files.entries) {
        await File(p.join(dir.path, entry.key)).writeAsString(entry.value);
      }
      final repo = TranslationRepositoryImpl(ds);
      final loader = LoadArbFolder(repo);
      final (base, locales, entries) = await loader(dir.path);
      final container = ProviderContainer();
      final controller = container.read(projectControllerProvider.notifier);
      final sub = container.listen(projectControllerProvider, (_, _) {});
      // tie disposal to container
      addTearDown(() async {
        sub.close();
        container.dispose();
        if (await dir.exists()) await dir.delete(recursive: true);
      });
      controller.state = ProjectState(
        folderPath: dir.path,
        baseLocale: base,
        locales: locales,
        entries: entries,
      );
      return (container, controller);
    }

    test('rename key persists after save & clears dirty', () async {
      final (container, controller) = await loadTemp({
        'app_en.arb':
            '{"@@locale":"en","hello":"Hello","@hello":{"description":"Hi"}}',
        'app_de.arb': '{"@@locale":"de","hello":"Hallo"}',
      });
      controller.renameKey(oldKey: 'hello', newKey: 'greeting');
      expect(
        controller.state.dirtyCells.where((c) => c.$1 == 'greeting').length,
        controller.state.locales.length,
      );
      await controller.saveAll();
      expect(controller.state.dirtyCells, isEmpty);
      expect(controller.state.hasUnsavedChanges, isFalse);
      // reload to verify
      final repo = TranslationRepositoryImpl(ds);
      final loader = LoadArbFolder(repo);
      final (_, _, entries2) = await loader(controller.state.folderPath!);
      expect(entries2.any((e) => e.key == 'greeting'), isTrue);
      expect(entries2.any((e) => e.key == 'hello'), isFalse);
      final enFile = await File(
        p.join(controller.state.folderPath!, 'app_en.arb'),
      ).readAsString();
      expect(enFile.contains('@greeting'), isTrue);
      expect(enFile.contains('@hello'), isFalse);
    });

    test('delete key removed after save & reload', () async {
      final (container, controller) = await loadTemp({
        'app_en.arb': '{"@@locale":"en","a":"1","b":"2"}',
        'app_de.arb': '{"@@locale":"de","a":"1","b":"2"}',
      });
      controller.deleteKey('b');
      await controller.saveAll();
      final repo = TranslationRepositoryImpl(ds);
      final loader = LoadArbFolder(repo);
      final (_, _, entries2) = await loader(controller.state.folderPath!);
      expect(entries2.any((e) => e.key == 'b'), isFalse);
      expect(entries2.any((e) => e.key == 'a'), isTrue);
    });

    test('combined filters (errors ∩ untranslated)', () async {
      final (container, controller) = await loadTemp({
        'app_en.arb':
            '{"@@locale":"en","combo":"Hi {name}","@combo":{"placeholders":{"name":{}}}}',
        'app_de.arb': '{"@@locale":"de","combo":"Hi"}',
        'app_fr.arb': '{"@@locale":"fr"}',
      });
      // Trigger placeholder validation by editing de value to different (still missing placeholder)
      controller.updateCell(key: 'combo', locale: 'de', text: 'HiX');
      // Sanity: error present
      expect(controller.state.errorCells.contains(('combo', 'de')), isTrue);
      // Apply errors filter -> key appears
      controller.toggleFilterErrors();
      expect(container.read(filteredEntriesProvider).map((e) => e.key), [
        'combo',
      ]);
      // Apply untranslated filter as well (fr empty) -> still present
      controller.toggleFilterUntranslated();
      expect(container.read(filteredEntriesProvider).map((e) => e.key), [
        'combo',
      ]);
      // Removing errors filter leaves untranslated still -> still present
      controller.toggleFilterErrors();
      expect(container.read(filteredEntriesProvider).map((e) => e.key), [
        'combo',
      ]);
    });
  });
}
