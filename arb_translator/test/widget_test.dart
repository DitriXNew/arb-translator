import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arb_translator/src/app.dart';

void main() {
  testWidgets('App builds smoke test', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ArbTranslatorApp()));
    // Just ensure root widget appears.
    expect(find.text('Select a folder to start'), findsOneWidget);
  });
}
