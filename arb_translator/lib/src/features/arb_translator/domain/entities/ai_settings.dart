class AiSettings {
  const AiSettings({
    this.apiKeyMasked,
    this.glossaryPrompt = '',
    this.openAiModel = 'gpt-5-mini', // fixed
  });
  final String? apiKeyMasked;
  final String glossaryPrompt;
  // Model now fixed (no user editing / persistence)
  final String openAiModel;

  AiSettings copyWith({
    String? apiKeyMasked,
    String? glossaryPrompt,
    String? openAiModel, // kept for API compatibility (ignored externally)
  }) => AiSettings(
    apiKeyMasked: apiKeyMasked ?? this.apiKeyMasked,
    glossaryPrompt: glossaryPrompt ?? this.glossaryPrompt,
    openAiModel: openAiModel ?? this.openAiModel,
  );
}
