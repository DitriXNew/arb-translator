import 'package:arb_translator/src/features/arb_translator/application/services/batch_translation_runner.dart';
import 'package:arb_translator/src/features/arb_translator/domain/ai/ai_strategy_ids.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/ai_settings.dart';
import 'package:args/args.dart';

/// Which cells a run translates.
enum TranslateMode {
  /// Empty cells and cells whose base text changed since they were translated.
  missing,

  /// Every cell with base text, overwriting existing translations.
  all,
}

/// Thrown for a command line that cannot run; the message is shown with the usage.
class CliUsageException implements Exception {
  const CliUsageException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Parsed, validated options of `arb_translator_cli`.
class CliOptions {
  const CliOptions({
    required this.directory,
    required this.mode,
    required this.provider,
    required this.model,
    required this.batchSize,
    required this.removeOrphans,
    required this.dryRun,
    this.locales,
    this.keys,
    this.endpoint,
    this.apiKey,
    this.glossaryFile,
  });

  /// Folder holding the ARB files (base template plus locale files).
  final String directory;

  /// Target locales; null means every non-base locale found in [directory].
  final List<String>? locales;

  /// Restricts the run to these keys; null means all keys.
  final Set<String>? keys;
  final TranslateMode mode;
  final String provider;
  final String model;
  final Uri? endpoint;
  final String? apiKey;
  final String? glossaryFile;
  final int batchSize;
  final bool removeOrphans;
  final bool dryRun;

  static const _providers = [AiStrategyIds.openAi, AiStrategyIds.mock];

  static final ArgParser parser = ArgParser()
    ..addOption('dir', abbr: 'd', help: 'Folder with the ARB files (template and locales). Required.')
    ..addOption(
      'locales',
      abbr: 'l',
      help:
          'Comma-separated target locales, e.g. de,fr. A locale without a file gets one. Default: every locale found.',
    )
    ..addOption(
      'mode',
      allowed: TranslateMode.values.map((m) => m.name),
      defaultsTo: TranslateMode.missing.name,
      allowedHelp: {
        TranslateMode.missing.name: 'Empty translations and translations of changed base text.',
        TranslateMode.all.name: 'Every key, overwriting existing translations.',
      },
    )
    ..addOption('keys', abbr: 'k', help: 'Comma-separated keys to limit the run to.')
    ..addFlag('remove-orphans', negatable: false, help: 'Delete keys that locale files have but the template does not.')
    ..addOption('provider', allowed: _providers, defaultsTo: AiStrategyIds.openAi)
    ..addOption('model', defaultsTo: kDefaultAiModel, help: 'Model name sent to the provider.')
    ..addOption('endpoint', help: 'Chat-completions URL of an OpenAI-compatible server. Default: OpenAI.')
    ..addOption('api-key', help: 'API key. Default: the OPENAI_API_KEY environment variable.')
    ..addOption('glossary-file', help: 'Text file with glossary / style instructions added to every prompt.')
    ..addOption('batch-size', defaultsTo: '$kTranslationBatchSize', help: 'Keys per request.')
    ..addFlag('dry-run', negatable: false, help: 'Report what would change; call no provider, write no file.')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show this help.');

  /// Parses [arguments]; [environment] supplies `OPENAI_API_KEY` when `--api-key` is absent.
  ///
  /// Throws [CliUsageException] for anything that cannot run. Returns null when help was asked for.
  static CliOptions? parse(List<String> arguments, {Map<String, String> environment = const {}}) {
    final ArgResults results;
    try {
      results = parser.parse(arguments);
    } on FormatException catch (e) {
      throw CliUsageException(e.message);
    }
    if (results.flag('help')) return null;
    if (results.rest.isNotEmpty) throw CliUsageException('Unexpected argument(s): ${results.rest.join(' ')}');

    final directory = results.option('dir');
    if (directory == null || directory.trim().isEmpty) throw const CliUsageException('--dir is required.');

    final batchSize = int.tryParse(results.option('batch-size')!);
    if (batchSize == null || batchSize < 1) throw const CliUsageException('--batch-size must be a positive integer.');

    final endpointText = results.option('endpoint');
    final endpoint = endpointText == null ? null : Uri.tryParse(endpointText);
    if (endpointText != null && (endpoint == null || !endpoint.hasScheme)) {
      throw CliUsageException('--endpoint is not a URL: $endpointText');
    }

    final apiKey = results.option('api-key') ?? environment['OPENAI_API_KEY'];
    return CliOptions(
      directory: directory,
      locales: _list(results.option('locales')),
      keys: _list(results.option('keys'))?.toSet(),
      mode: TranslateMode.values.byName(results.option('mode')!),
      provider: results.option('provider')!,
      model: results.option('model')!,
      endpoint: endpoint,
      apiKey: (apiKey == null || apiKey.trim().isEmpty) ? null : apiKey.trim(),
      glossaryFile: results.option('glossary-file'),
      batchSize: batchSize,
      removeOrphans: results.flag('remove-orphans'),
      dryRun: results.flag('dry-run'),
    );
  }

  static List<String>? _list(String? value) {
    if (value == null) return null;
    final items = [
      for (final part in value.split(','))
        if (part.trim().isNotEmpty) part.trim(),
    ];
    if (items.isEmpty) throw CliUsageException('Empty list: "$value"');
    return items;
  }
}
