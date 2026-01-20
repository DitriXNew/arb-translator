import 'dart:convert';
import 'package:arb_translator/src/core/services/log_service.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/ai_settings.dart';
import 'package:http/http.dart' as http;

/// Item for batch translation
class TranslationItem {
  const TranslationItem({required this.key, required this.text, this.description});

  final String key;
  final String text;
  final String? description;
}

class OpenAiRemoteDataSource {
  OpenAiRemoteDataSource(this.client);
  final http.Client client;

  /// Batch size for structured output
  static const int batchSize = 100;

  Future<String> translate({
    required String apiKey,
    required String prompt,
    String model = kDefaultAiModel,
    Uri? endpoint,
  }) async {
    logDebug('Starting OpenAI translation request: model=$model');

    final uri = endpoint ?? Uri.parse('https://api.openai.com/v1/chat/completions');

    http.Response resp;
    int attempt = 0;
    while (true) {
      attempt++;
      final payload = <String, dynamic>{
        'model': model,
        'messages': [
          {'role': 'system', 'content': 'You are a translation engine.'},
          {'role': 'user', 'content': prompt},
        ],
      };
      final body = jsonEncode(payload);

      resp = await client.post(
        uri,
        headers: {'Authorization': 'Bearer $apiKey', 'Content-Type': 'application/json'},
        body: body,
      );

      logDebug('OpenAI response: status=${resp.statusCode}, body length=${resp.body.length}');

      if (resp.statusCode == 200) break;

      final retriable = resp.statusCode == 429 || (resp.statusCode >= 500 && resp.statusCode < 600);
      if (!retriable || attempt >= 3) {
        logError('OpenAI request failed: status=${resp.statusCode}, body=${resp.body}');
        throw Exception('AI translate failed: ${resp.statusCode}');
      }

      final delaySeconds = attempt; // simple linear backoff
      logWarning('OpenAI request failed (attempt $attempt), retrying in ${delaySeconds}s...');
      await Future.delayed(Duration(seconds: delaySeconds));
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final choices = data['choices'];
    if (choices is List && choices.isNotEmpty) {
      final msg = choices.first['message'];
      final content = msg?['content'];
      if (content is String) {
        logInfo('OpenAI translation successful: result length=${content.length} chars');
        return content.trim();
      }
    }
    throw Exception('Invalid AI response');
  }

  /// Validates API key by fetching available models
  Future<List<String>> getAvailableModels({required String apiKey, Uri? endpoint}) async {
    logDebug('Validating OpenAI API key...');

    final uri = endpoint ?? Uri.parse('https://api.openai.com/v1/models');

    final resp = await client.get(uri, headers: {'Authorization': 'Bearer $apiKey'});

    logDebug('API key validation response: status=${resp.statusCode}');

    if (resp.statusCode != 200) {
      logError('API key validation failed: status=${resp.statusCode}, body=${resp.body}');
      throw Exception('API key validation failed: ${resp.statusCode}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final models = data['data'] as List?;

    if (models == null) {
      logError('Invalid response format from OpenAI models API');
      throw Exception('Invalid response format');
    }

    final gptModels =
        models.map((model) => model['id'] as String?).whereType<String>().where((id) => id.startsWith('gpt-')).toList()
          ..sort();

    logInfo('API key validation successful. Found ${gptModels.length} GPT models');
    return gptModels;
  }

  /// Batch translation using structured output (JSON schema)
  /// Returns `Map<key, translation>`
  Future<Map<String, String>> translateBatch({
    required String apiKey,
    required List<TranslationItem> items,
    required String targetLocale,
    String? glossaryPrompt,
    String model = kDefaultAiModel,
    Uri? endpoint,
  }) async {
    if (items.isEmpty) return {};

    logInfo('Starting batch translation: ${items.length} items to $targetLocale, model=$model');

    final uri = endpoint ?? Uri.parse('https://api.openai.com/v1/chat/completions');

    // Build list of texts for translation
    final textsToTranslate = <Map<String, dynamic>>[
      for (final item in items)
        {
          'key': item.key,
          'text': item.text,
          if (item.description != null && item.description!.isNotEmpty) 'description': item.description,
        },
    ];

    // System prompt for translation
    final systemPrompt =
        '''
You are a professional translator for software localization.
Translate the provided texts from English to $targetLocale.
${glossaryPrompt != null && glossaryPrompt.isNotEmpty ? 'Glossary and style guide:\n$glossaryPrompt\n' : ''}
IMPORTANT:
- Preserve all placeholders like {name}, {count}, etc. exactly as they appear
- Keep the same formatting (newlines, punctuation)
- Translate naturally for the target locale
- Return translations for ALL provided keys''';

    // User prompt with JSON data
    final userPrompt =
        '''
Translate the following ${items.length} texts:

${jsonEncode(textsToTranslate)}''';

    // JSON Schema for structured output
    final jsonSchema = {
      'name': 'translations',
      'strict': true,
      'schema': {
        'type': 'object',
        'properties': {
          'translations': {
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'key': {'type': 'string'},
                'translation': {'type': 'string'},
              },
              'required': ['key', 'translation'],
              'additionalProperties': false,
            },
          },
        },
        'required': ['translations'],
        'additionalProperties': false,
      },
    };

    http.Response resp;
    int attempt = 0;

    while (true) {
      attempt++;
      final payload = <String, dynamic>{
        'model': model,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
        'response_format': {'type': 'json_schema', 'json_schema': jsonSchema},
      };
      final body = jsonEncode(payload);

      logDebug('Batch request payload size: ${body.length} bytes');

      resp = await client.post(
        uri,
        headers: {'Authorization': 'Bearer $apiKey', 'Content-Type': 'application/json'},
        body: body,
      );

      logDebug('Batch response: status=${resp.statusCode}, body length=${resp.body.length}');

      if (resp.statusCode == 200) break;

      final retriable = resp.statusCode == 429 || (resp.statusCode >= 500 && resp.statusCode < 600);
      if (!retriable || attempt >= 3) {
        logError('Batch translation failed: status=${resp.statusCode}, body=${resp.body}');
        throw Exception('AI batch translate failed: ${resp.statusCode}');
      }

      final delaySeconds = attempt * 2; // exponential backoff
      logWarning('Batch request failed (attempt $attempt), retrying in ${delaySeconds}s...');
      await Future.delayed(Duration(seconds: delaySeconds));
    }

    // Parse response
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final choices = data['choices'];
    if (choices is! List || choices.isEmpty) {
      throw Exception('Invalid AI response: no choices');
    }

    final msg = choices.first['message'];
    final content = msg?['content'];
    if (content is! String) {
      throw Exception('Invalid AI response: no content');
    }

    // Parse structured output
    final translationsData = jsonDecode(content) as Map<String, dynamic>;
    final translationsList = translationsData['translations'] as List?;
    if (translationsList == null) {
      throw Exception('Invalid AI response: no translations array');
    }

    final result = <String, String>{};
    for (final item in translationsList) {
      if (item is Map<String, dynamic>) {
        final key = item['key'] as String?;
        final translation = item['translation'] as String?;
        if (key != null && translation != null) {
          result[key] = translation;
        }
      }
    }

    logInfo('Batch translation successful: ${result.length}/${items.length} translations received');
    return result;
  }
}
