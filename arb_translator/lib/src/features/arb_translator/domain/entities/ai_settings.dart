/// Default AI model used for translations
const String kDefaultAiModel = 'gpt-6.1-sol';

class AiSettings {
  const AiSettings({this.apiKeyMasked, this.glossaryPrompt = '', this.openAiModel = kDefaultAiModel});
  final String? apiKeyMasked;
  final String glossaryPrompt;

  /// Model name sent to OpenAI; edited in the AI settings dialog.
  final String openAiModel;

  AiSettings copyWith({String? apiKeyMasked, String? glossaryPrompt, String? openAiModel}) => AiSettings(
    apiKeyMasked: apiKeyMasked ?? this.apiKeyMasked,
    glossaryPrompt: glossaryPrompt ?? this.glossaryPrompt,
    openAiModel: openAiModel ?? this.openAiModel,
  );
}
