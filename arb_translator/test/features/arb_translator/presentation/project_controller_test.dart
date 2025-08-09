import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_controller.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_state.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/entry_metadata.dart';

void main() {
  group('ProjectController basic mutations', () {
    test('updateCell marks dirty and validates placeholders', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(projectControllerProvider.notifier);
      // Seed state manually
      controller.state = const ProjectState(
        baseLocale: 'en',
        locales: ['en', 'de'],
        entries: [
          TranslationEntry(
            key: 'hello',
            meta: EntryMetadata(placeholders: {'name'}),
            values: {'en': 'Hello {name}', 'de': ''},
          ),
        ],
      );
      controller.updateCell(key: 'hello', locale: 'de', text: 'Hallo {name}');
      final s = container.read(projectControllerProvider);
      expect(s.dirtyCells.contains(('hello', 'de')), isTrue);
      expect(s.errorCells.contains(('hello', 'de')), isFalse);
    });

    test('updateCell adds error on placeholder mismatch', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(projectControllerProvider.notifier);
      controller.state = const ProjectState(
        baseLocale: 'en',
        locales: ['en', 'fr'],
        entries: [
          TranslationEntry(
            key: 'greet',
            meta: EntryMetadata(placeholders: {'user'}),
            values: {'en': 'Hi {user}', 'fr': ''},
          ),
        ],
      );
      controller.updateCell(key: 'greet', locale: 'fr', text: 'Salut');
      final s = container.read(projectControllerProvider);
      expect(s.errorCells.contains(('greet', 'fr')), isTrue);
    });

    test(
      'renameKey enforces uniqueness and marks all locales dirty for key',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final controller = container.read(projectControllerProvider.notifier);
        controller.state = const ProjectState(
          baseLocale: 'en',
          locales: ['en', 'de'],
          entries: [
            TranslationEntry(key: 'a', values: {'en': '1', 'de': '1'}),
            TranslationEntry(key: 'b', values: {'en': '2', 'de': '2'}),
          ],
        );
        controller.renameKey(oldKey: 'a', newKey: 'b'); // duplicate -> ignored
        expect(controller.state.entries.first.key, 'a');
        controller.renameKey(oldKey: 'a', newKey: 'c');
        final s = controller.state;
        expect(s.entries.any((TranslationEntry e) => e.key == 'c'), isTrue);
        expect(
          s.dirtyCells.where(((String, String) c) => c.$1 == 'c').length,
          2,
        ); // both locales
      },
    );

    test('deleteKey removes entry and marks unsaved', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(projectControllerProvider.notifier);
      controller.state = const ProjectState(
        baseLocale: 'en',
        locales: ['en', 'de'],
        entries: [
          TranslationEntry(key: 'a', values: {'en': '1', 'de': '1'}),
          TranslationEntry(key: 'b', values: {'en': '2', 'de': '2'}),
        ],
      );
      controller.deleteKey('a');
      final s = controller.state;
      expect(s.entries.length, 1);
      expect(s.hasUnsavedChanges, isTrue);
    });
  });
}
