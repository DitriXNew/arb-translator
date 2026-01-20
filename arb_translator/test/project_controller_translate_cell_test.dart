import 'package:arb_translator/src/features/arb_translator/domain/ai/ai_translation_strategy.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/ai_settings.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_providers.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_settings_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

class _MockStrategy implements AiTranslationStrategy {
  @override
  String get id => 'mock';
  @override
  String get label => 'Mock';
  @override
  Future<String> translate({
    required String apiKey,
    required String englishText,
    required String targetLocale,
    String? description,
    String? glossaryPrompt,
  }) async {
    return '[${targetLocale.toUpperCase()}] $englishText';
  }

  @override
  Future<Map<String, String>> translateBatch({
    required String apiKey,
    required List<BatchTranslationItem> items,
    required String targetLocale,
    String? glossaryPrompt,
  }) async {
    return {for (final item in items) item.key: '[${targetLocale.toUpperCase()}] ${item.text}'};
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('translateCell updates target locale value, preserves placeholder, marks dirty', () async {
    final container = ProviderContainer(
      overrides: [
        aiStrategyProvider.overrideWithValue(_MockStrategy()),
        aiSettingsProvider.overrideWith(() => _FakeAiSettingsNotifier()),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(projectControllerProvider.notifier);
    // Seed state manually with one entry having placeholder
    final initial = container.read(projectControllerProvider);
    final entry = TranslationEntry(key: 'hello', values: const {'en': 'Hello {name}', 'fr': ''});
    controller.state = initial.copyWith(locales: const ['en', 'fr'], entries: [entry]);

    await controller.translateCell(key: 'hello', locale: 'fr');

    final st = container.read(projectControllerProvider);
    expect(st.entries.single.values['fr'], startsWith('[FR] Hello'));
    expect(st.entries.single.values['fr']!.contains('{name}'), isTrue, reason: 'Placeholder must be preserved');
    expect(st.dirtyCells.contains(('hello', 'fr')), isTrue);
  });
}

class _FakeAiSettingsNotifier extends AiSettingsNotifier {
  @override
  AiSettings build() => const AiSettings(apiKeyMasked: '***', glossaryPrompt: '');
  @override
  Future<String?> readFullKey() async => 'test-key';
}
