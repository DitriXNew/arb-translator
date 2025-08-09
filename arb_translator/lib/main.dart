import 'package:arb_translator/src/app.dart';
import 'package:arb_translator/src/core/services/log_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logging service
  await LogService().initialize();
  logInfo('ARB Translator application starting...');

  runApp(const ProviderScope(child: ArbTranslatorApp()));
}
