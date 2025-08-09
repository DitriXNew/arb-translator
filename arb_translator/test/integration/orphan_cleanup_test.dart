import 'dart:io';

import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

/// Integration-style test validating orphan cleanup deletes keys absent from base locale file.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Orphan cleanup', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('arb_orphan_test');
      // Base English file missing key 'only_de' while German file has it.
      final enFile = File(p.join(tempDir.path, 'app_en.arb'));
      await enFile.writeAsString('''{
  "@@locale": "en",
  "hello": "Hello"
}''');
      final deFile = File(p.join(tempDir.path, 'app_de.arb'));
      await deFile.writeAsString('''{
  "@@locale": "de",
  "hello": "Hallo",
  "only_de": "Nur Deutsch"
}''');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('removes non-base keys and keeps base keys', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(projectControllerProvider.notifier);

      await controller.loadFolder(tempDir.path);
      final initial = container.read(projectControllerProvider).entries;
      expect(initial.map((e) => e.key).toSet(), {'hello', 'only_de'});

      controller.removeKeysMissingInEnglish();
      final after = container.read(projectControllerProvider).entries;

      // 'only_de' should be removed, 'hello' retained.
      expect(after.map((e) => e.key).toSet(), {'hello'});
      // state should be marked dirty (unsaved changes)
      expect(container.read(projectControllerProvider).hasUnsavedChanges, isTrue);

      // Perform second cleanup should do nothing further.
      controller.removeKeysMissingInEnglish();
      final afterSecond = container.read(projectControllerProvider).entries;
      expect(afterSecond.map((e) => e.key).toSet(), {'hello'});
    });
  });
}
