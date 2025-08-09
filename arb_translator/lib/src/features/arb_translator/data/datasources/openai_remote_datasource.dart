import 'dart:convert';
import 'package:arb_translator/src/core/services/log_service.dart';
import 'package:http/http.dart' as http;

class OpenAiRemoteDataSource {
  OpenAiRemoteDataSource(this.client);
  final http.Client client;

  Future<String> translate({
    required String apiKey,
    required String prompt,
    String model = 'gpt-5-mini',
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
}
