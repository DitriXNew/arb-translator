import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_errors_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('AiErrorsNotifier add + sanitize + clear', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(aiErrorsProvider.notifier);
    notifier.add(key: 'k1', locale: 'de', message: 'failed because apiKey invalid');
    notifier.add(key: 'k2', locale: 'fr', message: 'timeout');
    final list = container.read(aiErrorsProvider);
    expect(list.length, 2);
    // Newest first
    expect(list.first.key, 'k2');
    // Sanitization
    final msgSanitized = list.last.message.toLowerCase();
    expect(msgSanitized.contains('apikey'), isFalse);
    expect(msgSanitized.contains('api'), isTrue); // Still contains other parts
    notifier.clear();
    expect(container.read(aiErrorsProvider).isEmpty, true);
  });
}
