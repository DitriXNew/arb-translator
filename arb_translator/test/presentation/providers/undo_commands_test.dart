import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_controller.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';

void main() {
  group('Undo commands', () {
    late ProviderContainer container;
    setUp(() {
      container = ProviderContainer();
      final ctrl = container.read(projectControllerProvider.notifier);
      ctrl.state = ctrl.state.copyWith(
        baseLocale: 'en',
        locales: ['en', 'fr'],
        entries: [
          const TranslationEntry(key: 'k', values: {'en': 'Hi', 'fr': ''}),
        ],
      );
    });
    tearDown(() => container.dispose());

    test('update cell undo/redo', () {
      final ctrl = container.read(projectControllerProvider.notifier);
      ctrl.updateCell(key: 'k', locale: 'fr', text: 'Salut');
      expect(
        container.read(projectControllerProvider).entries.first.values['fr'],
        'Salut',
      );
      ctrl.undo();
      expect(
        container.read(projectControllerProvider).entries.first.values['fr'],
        '',
      );
      ctrl.redo();
      expect(
        container.read(projectControllerProvider).entries.first.values['fr'],
        'Salut',
      );
    });

    test('rename key undo/redo', () {
      final ctrl = container.read(projectControllerProvider.notifier);
      ctrl.renameKey(oldKey: 'k', newKey: 'k2');
      expect(container.read(projectControllerProvider).entries.first.key, 'k2');
      ctrl.undo();
      expect(container.read(projectControllerProvider).entries.first.key, 'k');
      ctrl.redo();
      expect(container.read(projectControllerProvider).entries.first.key, 'k2');
    });

    test('delete key undo/redo', () {
      final ctrl = container.read(projectControllerProvider.notifier);
      ctrl.deleteKey('k');
      expect(container.read(projectControllerProvider).entries.isEmpty, isTrue);
      ctrl.undo();
      expect(container.read(projectControllerProvider).entries.length, 1);
      ctrl.redo();
      expect(container.read(projectControllerProvider).entries.isEmpty, isTrue);
    });
  });
}
