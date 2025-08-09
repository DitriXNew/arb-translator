import 'package:flutter_riverpod/flutter_riverpod.dart';

class AiTranslationError {
  const AiTranslationError({required this.key, required this.locale, required this.message, required this.timestamp});
  final String key;
  final String locale;
  final String message;
  final DateTime timestamp;
}

class AiErrorsNotifier extends Notifier<List<AiTranslationError>> {
  @override
  List<AiTranslationError> build() => const [];

  void add({required String key, required String locale, required String message}) {
    // Avoid leaking API key accidentally in message (basic safeguard)
    // Keep the 'api' prefix so tests (and potential matching) can still see generic 'api'
    // while masking the sensitive key portion. Examples:
    //   apiKey -> api***
    //   API-KEY -> API***
    //   api_key -> api***
    final sanitized = message.replaceAllMapped(RegExp('api[_-]?key', caseSensitive: false), (m) {
      final original = m.group(0)!; // preserve original casing of 'api'
      // Split original into 'api' + the rest (key / -key / _key)
      final apiPrefixMatch = RegExp('api', caseSensitive: false).firstMatch(original)!;
      final apiPart = original.substring(apiPrefixMatch.start, apiPrefixMatch.end);
      return '$apiPart***';
    });
    state = [AiTranslationError(key: key, locale: locale, message: sanitized, timestamp: DateTime.now()), ...state];
  }

  void clear() => state = const [];
}

final aiErrorsProvider = NotifierProvider<AiErrorsNotifier, List<AiTranslationError>>(AiErrorsNotifier.new);
