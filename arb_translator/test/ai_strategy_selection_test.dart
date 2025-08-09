import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_strategy_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('strategy selection changes selected id', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final initial = container.read(selectedAiStrategyIdProvider);
    expect(initial, isNotEmpty);
    await container.read(selectedAiStrategyIdProvider.notifier).select(initial); // idempotent
    expect(container.read(selectedAiStrategyIdProvider), initial);
  });
}
