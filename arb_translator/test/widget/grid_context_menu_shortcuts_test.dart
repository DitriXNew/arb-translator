import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/widgets/grid.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_controller.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_state.dart';

// Simple fake controller via provider override capturing calls.
class _FakeController extends ProjectController {
  final List<String> calls = [];
  @override
  ProjectState build() => const ProjectState(
    baseLocale: 'en',
    locales: ['en', 'de'],
    entries: [
      // Minimal one row
    ],
  );
  @override
  Future<void> saveAll() async {
    calls.add('save');
  }

  @override
  void undo() {
    calls.add('undo');
  }

  @override
  void redo() {
    calls.add('redo');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('F2 without selection does nothing (no crash)', (tester) async {
    final fake = _FakeController();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [projectControllerProvider.overrideWith(() => fake)],
        child: const MaterialApp(home: Scaffold(body: TranslationGrid())),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.f2);
    await tester.pump();
    expect(fake.calls.isEmpty, true); // no change
  });

  testWidgets('Ctrl+S triggers saveAll via action', (tester) async {
    final fake = _FakeController();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [projectControllerProvider.overrideWith(() => fake)],
        child: const MaterialApp(home: Scaffold(body: TranslationGrid())),
      ),
    );
    await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
    await tester.pump();
    expect(fake.calls.contains('save'), true);
  });
}
