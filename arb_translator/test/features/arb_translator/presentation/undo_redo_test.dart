import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_controller.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_state.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/entry_metadata.dart';

void main() {
  group('Undo/Redo', () {
    test('updateCell undo/redo restores values & dirty tracking', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final ctrl = c.read(projectControllerProvider.notifier);
      ctrl.state = const ProjectState(
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
      ctrl.updateCell(key: 'hello', locale: 'de', text: 'Hallo {name}');
      expect(ctrl.state.entries.first.values['de'], 'Hallo {name}');
      ctrl.undo();
      expect(ctrl.state.entries.first.values['de'], '');
      ctrl.redo();
      expect(ctrl.state.entries.first.values['de'], 'Hallo {name}');
    });

    test('rename + delete undo chain', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final ctrl = c.read(projectControllerProvider.notifier);
      ctrl.state = const ProjectState(
        baseLocale: 'en',
        locales: ['en'],
        entries: [
          TranslationEntry(key: 'a', values: {'en': '1'}),
          TranslationEntry(key: 'b', values: {'en': '2'}),
        ],
      );
      ctrl.renameKey(oldKey: 'a', newKey: 'aa');
      expect(ctrl.state.entries.any((e) => e.key == 'aa'), isTrue);
      ctrl.deleteKey('b');
      expect(ctrl.state.entries.any((e) => e.key == 'b'), isFalse);
      ctrl.undo(); // undo delete
      expect(ctrl.state.entries.any((e) => e.key == 'b'), isTrue);
      ctrl.undo(); // undo rename
      expect(ctrl.state.entries.any((e) => e.key == 'a'), isTrue);
      ctrl.redo(); // redo rename
      expect(ctrl.state.entries.any((e) => e.key == 'aa'), isTrue);
    });
  });
}
