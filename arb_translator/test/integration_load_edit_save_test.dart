import 'dart:convert';
import 'dart:io';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Integration scope – using real file IO.

  group('Integration: load -> edit -> save -> reload', () {
    late Directory tempDir;
    late ProviderContainer container;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('arb_translator_test');
      // create sample en & fr
      final en = {
        '@@locale': 'en',
        'hello': 'Hello {name}',
        '@hello': {
          'description': 'Greeting',
          'placeholders': {'name': {}},
        },
        'bye': 'Bye',
      };
      final fr = {'@@locale': 'fr', 'hello': 'Bonjour {name}', 'bye': ''};
      await File('${tempDir.path}/app_en.arb').writeAsString(const JsonEncoder.withIndent('  ').convert(en));
      await File('${tempDir.path}/app_fr.arb').writeAsString(const JsonEncoder.withIndent('  ').convert(fr));
      // Debug: read back contents
      final enContent = await File('${tempDir.path}/app_en.arb').readAsString();
      final frContent = await File('${tempDir.path}/app_fr.arb').readAsString();
      // Print to test output
      // ignore: avoid_print
      print('DEBUG en.arb:\n$enContent');
      // ignore: avoid_print
      print('DEBUG fr.arb:\n$frContent');
      container = ProviderContainer();
      addTearDown(container.dispose);
      // Keep controller alive to avoid auto-dispose between async gaps
      final sub = container.listen(projectControllerProvider, (_, __) {});
      addTearDown(sub.close);
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('cycle persists edits', () async {
      final controller = container.read(projectControllerProvider.notifier);
      await controller.loadFolder(tempDir.path, rethrowOnError: true);
      final st1 = container.read(projectControllerProvider);
      expect(st1.isLoading, isFalse);
      if (st1.entries.isEmpty) {
        final files = Directory(tempDir.path).listSync().map((e) => e.path.split('\\').last).toList();
        fail('Entries empty. Files present: $files');
      }
      // edit fr bye
      controller.updateCell(key: 'bye', locale: 'fr', text: 'Au revoir');
      await controller.saveAll();
      // reload new container to ensure persisted
      final container2 = ProviderContainer();
      addTearDown(container2.dispose);
      // Attach listener BEFORE starting async load to keep provider alive (autoDispose workaround)
      final sub2 = container2.listen(projectControllerProvider, (_, __) {});
      addTearDown(sub2.close);
      final controller2 = container2.read(projectControllerProvider.notifier);
      // Debug: print saved file contents
      final savedEn = await File('${tempDir.path}/app_en.arb').readAsString();
      final savedFr = await File('${tempDir.path}/app_fr.arb').readAsString();
      // ignore: avoid_print
      print('DEBUG saved en.arb after saveAll:\n$savedEn');
      // ignore: avoid_print
      print('DEBUG saved fr.arb after saveAll:\n$savedFr');
      await controller2.loadFolder(tempDir.path, rethrowOnError: true);
      final st2 = container2.read(projectControllerProvider);
      expect(st2.isLoading, isFalse);
      expect(st2.entries.isNotEmpty, isTrue);
      final state2 = container2.read(projectControllerProvider);
      expect(state2.entries.isNotEmpty, true);
      final byeEntry = state2.entries.firstWhere((e) => e.key == 'bye', orElse: () => throw 'bye missing');
      expect(byeEntry.values['fr'], 'Au revoir');
      // placeholder metadata preserved only in en
      final hello = state2.entries.firstWhere((e) => e.key == 'hello', orElse: () => throw 'hello missing');
      expect(hello.meta.placeholders.contains('name'), isTrue);
    });
  });
}
