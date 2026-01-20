import 'package:arb_translator/src/features/arb_translator/application/services/translation_batch_executor.dart';
import 'package:arb_translator/src/features/arb_translator/domain/ai/ai_translation_strategy.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_strategy_registry.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/ai_settings.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_settings_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_controller.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/translation_progress_provider.dart';
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
    return '$englishText<$targetLocale>';
  }

  @override
  Future<Map<String, String>> translateBatch({
    required String apiKey,
    required List<BatchTranslationItem> items,
    required String targetLocale,
    String? glossaryPrompt,
  }) async {
    return {for (final item in items) item.key: '${item.text}<$targetLocale>'};
  }
}

class _FakeAiSettings extends AiSettingsNotifier {
  @override
  Future<String?> readFullKey() async => 'key';
  @override
  AiSettings build() => const AiSettings(apiKeyMasked: '***');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TranslationBatchExecutor', () {
    test('onlyEmpty=true translates only empty target cells', () async {
      final container = ProviderContainer(
        overrides: [
          currentAiStrategyProvider.overrideWithValue(_MockStrategy()),
          aiSettingsProvider.overrideWith(() => _FakeAiSettings()),
        ],
      );
      addTearDown(container.dispose);
      final ctrl = container.read(projectControllerProvider.notifier);
      final initial = container.read(projectControllerProvider);
      ctrl.state = initial.copyWith(
        locales: const ['en', 'fr'],
        entries: [
          TranslationEntry(key: 'a', values: const {'en': 'Hello', 'fr': ''}),
          TranslationEntry(key: 'b', values: const {'en': 'World', 'fr': 'Monde'}),
        ],
      );
      await container.read(translationBatchExecutorProvider).run(targetLocale: 'fr', onlyEmpty: true);
      final st = container.read(projectControllerProvider);
      expect(st.entries[0].values['fr'], 'Hello<fr>'); // was empty
      expect(st.entries[1].values['fr'], 'Monde'); // unchanged
      final prog = container.read(translationProgressProvider);
      expect(prog.isTranslating, false);
      expect(prog.done, 1);
      expect(prog.total, 1);
    });
  });
}
