import 'package:arb_translator/src/core/theme/app_theme.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/views/project_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArbTranslatorApp extends ConsumerWidget {
  const ArbTranslatorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'ARB Translator',
    theme: buildAppTheme(),
    darkTheme: buildAppTheme(),
    themeMode: ThemeMode.dark,
    home: const ProjectPage(),
  );
}
