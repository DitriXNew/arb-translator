import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_controller.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_state.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  group('ProjectController basic mutations', () {
    late ProviderContainer container;
    late ProjectController controller;

    setUp(() {
      container = ProviderContainer();
      addTearDown(container.dispose);
      controller = container.read(projectControllerProvider.notifier);
      // Seed minimal state manually (bypassing loadFolder) for unit mutation tests.
      controller.state = ProjectState(
        folderPath: 'tmp',
        baseLocale: 'en',
        locales: ['en', 'fr'],
        entries: [
          // simple entry with english only
          // ignore: prefer_const_constructors
          TranslationEntry(key: 'hello', values: {'en': 'Hello'}),
        ],
      );
    });

    test('updateCell marks dirty and stores value', () {
      controller.updateCell(key: 'hello', locale: 'fr', text: 'Bonjour');
      final st = container.read(projectControllerProvider);
      expect(st.entries.first.values['fr'], 'Bonjour');
      expect(st.dirtyCells.contains(('hello', 'fr')), isTrue);
      expect(st.hasUnsavedChanges, isTrue);
    });

    test('renameKey updates key and marks cells dirty', () {
      controller.updateCell(key: 'hello', locale: 'fr', text: 'Bonjour');
      controller.renameKey(oldKey: 'hello', newKey: 'greeting');
      final st = container.read(projectControllerProvider);
      expect(st.entries.first.key, 'greeting');
      expect(st.dirtyCells.any((c) => c.$1 == 'greeting'), isTrue);
    });

    test('deleteKey removes entry', () {
      controller.deleteKey('hello');
      final st = container.read(projectControllerProvider);
      expect(st.entries.isEmpty, isTrue);
      expect(st.hasUnsavedChanges, isTrue);
    });
  });
}
