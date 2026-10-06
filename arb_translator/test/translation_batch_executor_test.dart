import 'package:arb_translator/src/features/arb_translator/application/services/translation_batch_executor.dart';
import 'package:arb_translator/src/features/arb_translator/domain/ai/ai_translation_strategy.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_errors_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_strategy_registry.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/ai_settings.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_settings_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/locale_translation_progress_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_controller.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/translation_progress_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

/// Answers `text<locale>`; [onBatch] runs first and may throw or drop keys from the answer.
class _MockStrategy implements AiTranslationStrategy {
  _MockStrategy({this.onBatch});
  final Set<String>? Function(List<BatchTranslationItem> items)? onBatch;
  var batches = 0;

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
    batches++;
    final dropped = onBatch?.call(items) ?? const {};
    return {
      for (final item in items)
        if (!dropped.contains(item.key)) item.key: '${item.text}<$targetLocale>',
    };
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
    ProviderContainer containerWith(_MockStrategy strategy, List<TranslationEntry> entries) {
      final container = ProviderContainer(
        overrides: [
          currentAiStrategyProvider.overrideWithValue(strategy),
          aiSettingsProvider.overrideWith(() => _FakeAiSettings()),
        ],
      );
      addTearDown(container.dispose);
      final ctrl = container.read(projectControllerProvider.notifier);
      ctrl.state = container.read(projectControllerProvider).copyWith(locales: const ['en', 'fr'], entries: entries);
      return container;
    }

    Future<void> run(ProviderContainer container) =>
        container.read(translationBatchExecutorProvider).run(targetLocale: 'fr', onlyEmpty: true);

    String? fr(ProviderContainer container, String key) =>
        container.read(projectControllerProvider).entries.firstWhere((e) => e.key == key).values['fr'];

    test('onlyEmpty=true translates only empty target cells', () async {
      final container = containerWith(_MockStrategy(), [
        TranslationEntry(key: 'a', values: const {'en': 'Hello', 'fr': ''}),
        TranslationEntry(key: 'b', values: const {'en': 'World', 'fr': 'Monde'}),
      ]);
      await run(container);
      expect(fr(container, 'a'), 'Hello<fr>'); // was empty
      expect(fr(container, 'b'), 'Monde'); // unchanged
      final prog = container.read(translationProgressProvider);
      expect(prog.isTranslating, false);
      expect(prog.done, 1);
      expect(prog.total, 1);
    });

    test('a cancel during a batch stops before the next one', () async {
      late ProviderContainer container;
      final strategy = _MockStrategy(
        onBatch: (_) {
          container.read(localeTranslationProgressProvider.notifier).requestCancel('fr');
          return null;
        },
      );
      container = containerWith(strategy, [
        for (var i = 0; i < kTranslationBatchSize + 1; i++)
          TranslationEntry(key: 'k${'$i'.padLeft(3, '0')}', values: const {'en': 'Text', 'fr': ''}),
      ]);

      await run(container);

      expect(strategy.batches, 1);
      expect(fr(container, 'k000'), 'Text<fr>', reason: 'the batch in flight still lands');
      expect(fr(container, 'k$kTranslationBatchSize'), '');
      expect(container.read(localeTranslationProgressProvider).isTranslating('fr'), isFalse);
      expect(container.read(translationProgressProvider).isTranslating, isFalse);
    });

    test('a thrown batch reports every key and still advances progress', () async {
      final container = containerWith(_MockStrategy(onBatch: (_) => throw StateError('quota')), [
        TranslationEntry(key: 'a', values: const {'en': 'Hello', 'fr': ''}),
        TranslationEntry(key: 'b', values: const {'en': 'World', 'fr': ''}),
      ]);

      await run(container);

      final errors = container.read(aiErrorsProvider);
      expect(errors.map((e) => e.key).toSet(), {'a', 'b'});
      expect(errors.every((e) => e.locale == 'fr' && e.message.contains('Batch translation failed')), isTrue);
      expect(fr(container, 'a'), '');
      final prog = container.read(translationProgressProvider);
      expect((prog.done, prog.total, prog.isTranslating), (2, 2, false));
    });

    test('a key missing from the answer is an error; the others are applied', () async {
      final container = containerWith(_MockStrategy(onBatch: (_) => {'b'}), [
        TranslationEntry(key: 'a', values: const {'en': 'Hello', 'fr': ''}),
        TranslationEntry(key: 'b', values: const {'en': 'World', 'fr': ''}),
      ]);

      await run(container);

      expect(fr(container, 'a'), 'Hello<fr>');
      expect(fr(container, 'b'), '');
      final errors = container.read(aiErrorsProvider);
      expect(errors.single.key, 'b');
      expect(errors.single.message, 'No translation received from AI');
    });
  });
}
