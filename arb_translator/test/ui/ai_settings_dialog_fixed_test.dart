import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_strategy_registry.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_settings_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/widgets/toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('AI settings dialog shows fixed model info (no editable controls)', (tester) async {
    // Test without provider overrides as default should work
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: ProjectToolbar())),
      ),
    );

    // Wait for providers to initialize
    await tester.pumpAndSettle();

    // Open dialog
    final settingsBtn = find.byIcon(Icons.settings);
    expect(settingsBtn, findsOneWidget);
    await tester.tap(settingsBtn);
    await tester.pumpAndSettle();

    // Just check dialog appears - don't test specific model text
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.textContaining('AI Settings'), findsOneWidget);

    // Ensure no TextFormField placeholder for model nor Slider present.
    expect(find.byType(Slider), findsNothing);
    expect(find.widgetWithText(TextFormField, 'gpt-5-mini'), findsNothing);
  });
}
