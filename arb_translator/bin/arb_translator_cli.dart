import 'dart:io';

import 'package:arb_translator/src/cli/arb_translate_command.dart';
import 'package:arb_translator/src/cli/cli_options.dart';

/// Headless ARB translation: `dart run arb_translator:arb_translator_cli --dir <folder> [options]`.
Future<void> main(List<String> arguments) async {
  final CliOptions? options;
  try {
    options = CliOptions.parse(arguments, environment: Platform.environment);
  } on CliUsageException catch (e) {
    stderr
      ..writeln(e.message)
      ..writeln()
      ..writeln(CliOptions.parser.usage);
    exit(CliExitCode.usage);
  }
  if (options == null) {
    stdout
      ..writeln('Usage: arb_translator_cli --dir <folder> [options]')
      ..writeln()
      ..writeln(CliOptions.parser.usage);
    return;
  }
  exitCode = await ArbTranslateCommand(out: stdout, err: stderr).run(options);
}
