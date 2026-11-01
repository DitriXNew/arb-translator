import 'package:arb_translator/src/features/arb_translator/domain/entities/ai_settings.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_strategy_registry.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_settings_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/widgets/toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('AI settings dialog has a model field prefilled with the default model', (tester) async {
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

    final modelFields = tester
        .widgetList<TextField>(find.byType(TextField))
        .where((f) => f.controller?.text == kDefaultAiModel);
    expect(modelFields, hasLength(1));
    expect(find.byType(Slider), findsNothing);
  });
}
