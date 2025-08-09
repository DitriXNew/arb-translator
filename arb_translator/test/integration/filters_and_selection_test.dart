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
  group('Filters & folder load integration', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('arb_filters');
      await File(p.join(tempDir.path, 'app_en.arb')).writeAsString('''{
  "@@locale": "en",
  "greet": "Hello {user}",
  "@greet": {"description": "Greeting", "placeholders": {"user": {}}},
  "bye": "Bye"
}''');
      await File(p.join(tempDir.path, 'app_es.arb')).writeAsString('''{
  "@@locale": "es",
  "greet": "Hola {user}"
}''');
    });

    tearDown(() async {
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    test('load folder then apply filters (errors / untranslated)', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(projectControllerProvider.notifier);
      final sub = container.listen(projectControllerProvider, (_, _) {});
      addTearDown(sub.close);
      final repo = TranslationRepositoryImpl(ArbFileDataSource());
      final loader = LoadArbFolder(repo);
      final (base, locales, entries) = await loader(tempDir.path);
      controller.state = ProjectState(
        folderPath: tempDir.path,
        baseLocale: base,
        locales: locales,
        entries: entries,
      );
      // Initially: 2 entries greet & bye
      expect(container.read(filteredEntriesProvider).length, 2);
      // Untranslated filter: es 'bye' empty -> expect only bye
      controller.toggleFilterUntranslated();
      expect(
        container.read(filteredEntriesProvider).map((e) => e.key).toList(),
        ['bye'],
      );
      // Clear untranslated filter
      controller.toggleFilterUntranslated();
      // Introduce placeholder error: remove placeholder in es greet
      controller.updateCell(key: 'greet', locale: 'es', text: 'Hola');
      expect(controller.state.errorCells.contains(('greet', 'es')), isTrue);
      // Apply errors filter -> only greet
      controller.toggleFilterErrors();
      expect(
        container.read(filteredEntriesProvider).map((e) => e.key).toList(),
        ['greet'],
      );
    });
  });
}
