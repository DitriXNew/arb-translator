import 'dart:convert';

import 'package:arb_translator/src/features/arb_translator/data/datasources/openai_remote_datasource.dart';
import 'package:arb_translator/src/features/arb_translator/domain/ai/ai_translation_strategy.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/ai_settings.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_providers.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_settings_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:riverpod/riverpod.dart';

class _FakeAiSettings extends AiSettingsNotifier {
  @override
  AiSettings build() => const AiSettings(openAiModel: 'custom-model');

  @override
  Future<void> setModel(String model) async => state = state.copyWith(openAiModel: model);
}

void main() {
  test('the OpenAI strategy sends the model from the settings', () async {
    final models = <String>[];
    final client = MockClient((request) async {
      models.add((json.decode(request.body) as Map)['model'] as String);
      return http.Response(
        json.encode({
          'choices': [
            {
              'message': {
                'content': json.encode({
                  'translations': [
                    {'key': 'k', 'translation': 'v'},
                  ],
                }),
              },
            },
          ],
        }),
        200,
      );
    });
    final container = ProviderContainer(
      overrides: [
        aiSettingsProvider.overrideWith(_FakeAiSettings.new),
        openAiDataSourceProvider.overrideWithValue(OpenAiRemoteDataSource(client)),
      ],
    );
    addTearDown(container.dispose);
    Future<void> translate() => container
        .read(aiStrategyProvider)
        .translateBatch(
          apiKey: 'k',
          items: const [BatchTranslationItem(key: 'k', text: 't')],
          targetLocale: 'de',
        );

    await translate();
    await container.read(aiSettingsProvider.notifier).setModel('changed-model');
    await translate();

    expect(models, ['custom-model', 'changed-model']);
  });
}
