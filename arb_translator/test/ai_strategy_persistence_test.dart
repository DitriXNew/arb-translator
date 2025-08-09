import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_strategy_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('selected strategy persists & reloads', () async {
    SharedPreferences.setMockInitialValues({});
    final c1 = ProviderContainer();
    addTearDown(c1.dispose);
    // Default should be openai.
    expect(c1.read(selectedAiStrategyIdProvider), 'openai');
    await c1.read(selectedAiStrategyIdProvider.notifier).select('mock');
    expect(c1.read(selectedAiStrategyIdProvider), 'mock');

    // New container simulates app restart.
    final c2 = ProviderContainer();
    addTearDown(c2.dispose);
    // Poll until loaded or timeout.
    for (var i = 0; i < 25; i++) {
      if (c2.read(selectedAiStrategyIdProvider) == 'mock') break;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(c2.read(selectedAiStrategyIdProvider), 'mock');
  });
}
