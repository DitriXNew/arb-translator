import 'package:arb_translator/src/features/arb_translator/presentation/providers/translation_progress_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('TranslationProgress lifecycle including cancel', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(translationProgressProvider.notifier);
    notifier.start(3);
    expect(container.read(translationProgressProvider).isTranslating, true);
    notifier.step();
    notifier.step();
    expect(container.read(translationProgressProvider).done, 2);
    notifier.cancel();
    expect(container.read(translationProgressProvider).cancelRequested, true);
    notifier.finish();
    final st = container.read(translationProgressProvider);
    expect(st.isTranslating, false);
    expect(st.done, 2); // finish does not auto-complete remaining steps
  });
}
