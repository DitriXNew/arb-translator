import 'package:arb_translator/src/core/services/log_service.dart';
import 'package:arb_translator/src/features/arb_translator/data/datasources/openai_remote_datasource.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/ai_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// Persistence keys.
const _kApiKey = 'ai_api_key';
const _kGlossary = 'ai_glossary_prompt';
const _kModel = 'ai_model';

final aiSettingsProvider = NotifierProvider<AiSettingsNotifier, AiSettings>(AiSettingsNotifier.new);

class AiSettingsNotifier extends Notifier<AiSettings> {
  late final FlutterSecureStorage _storage;

  @override
  AiSettings build() {
    _storage = const FlutterSecureStorage();
    _load();
    return const AiSettings();
  }

  Future<void> _load() async {
    final key = await _storage.read(key: _kApiKey);
    final glossary = await _storage.read(key: _kGlossary) ?? '';
    final model = await _storage.read(key: _kModel);
    state = state.copyWith(
      apiKeyMasked: _mask(key),
      glossaryPrompt: glossary,
      openAiModel: (model == null || model.isEmpty) ? null : model,
    );
  }

  String _mask(String? key) {
    if (key == null || key.length < 8) return key ?? '';
    return '${key.substring(0, 3)}***${key.substring(key.length - 3)}';
  }

  Future<void> setApiKey(String key) async {
    final trimmed = key.trim();
    await _storage.write(key: _kApiKey, value: trimmed);
    state = state.copyWith(apiKeyMasked: _mask(trimmed));
  }

  Future<void> clearApiKey() async {
    await _storage.delete(key: _kApiKey);
    state = state.copyWith();
  }

  Future<void> setGlossaryPrompt(String prompt) async {
    await _storage.write(key: _kGlossary, value: prompt);
    state = state.copyWith(glossaryPrompt: prompt);
  }

  /// Stores the model name; a blank [model] restores [kDefaultAiModel].
  Future<void> setModel(String model) async {
    final trimmed = model.trim();
    if (trimmed.isEmpty) {
      await _storage.delete(key: _kModel);
      state = state.copyWith(openAiModel: kDefaultAiModel);
    } else {
      await _storage.write(key: _kModel, value: trimmed);
      state = state.copyWith(openAiModel: trimmed);
    }
  }

  Future<String?> readFullKey() => _storage.read(key: _kApiKey);

  /// Validates API key by attempting to fetch available models
  Future<List<String>> validateApiKey(String apiKey) async {
    logInfo('Starting API key validation...');

    final dataSource = OpenAiRemoteDataSource(http.Client());
    try {
      final models = await dataSource.getAvailableModels(apiKey: apiKey);
      logInfo('API key validation successful: found ${models.length} models');
      return models;
    } catch (e) {
      logError('API key validation failed', e);
      throw Exception('API key validation failed: $e');
    } finally {
      dataSource.client.close();
    }
  }
}
