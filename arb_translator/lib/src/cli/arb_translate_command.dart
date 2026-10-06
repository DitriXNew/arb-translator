import 'dart:io';

import 'package:arb_translator/src/cli/cli_options.dart';
import 'package:arb_translator/src/core/utils/arb_utils.dart';
import 'package:arb_translator/src/features/arb_translator/application/services/batch_translation_runner.dart';
import 'package:arb_translator/src/features/arb_translator/data/ai/mock_strategy.dart';
import 'package:arb_translator/src/features/arb_translator/data/ai/openai_strategy.dart';
import 'package:arb_translator/src/features/arb_translator/data/datasources/arb_file_datasource.dart';
import 'package:arb_translator/src/features/arb_translator/data/datasources/arb_locale_file.dart';
import 'package:arb_translator/src/features/arb_translator/data/datasources/openai_remote_datasource.dart';
import 'package:arb_translator/src/features/arb_translator/data/repositories/translation_repository_impl.dart';
import 'package:arb_translator/src/features/arb_translator/domain/ai/ai_strategy_ids.dart';
import 'package:arb_translator/src/features/arb_translator/domain/ai/ai_translation_strategy.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';
import 'package:arb_translator/src/features/arb_translator/domain/services/translation_cells.dart';
import 'package:arb_translator/src/features/arb_translator/domain/usecases/load_arb_folder.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

/// Exit codes of `arb_translator_cli`.
class CliExitCode {
  static const ok = 0;

  /// The run finished, but at least one cell could not be translated.
  static const partialFailure = 1;

  /// The command line or the folder cannot be used (sysexits EX_USAGE).
  static const usage = 64;
}

/// Builds the strategy for a run; tests substitute their own.
typedef StrategyFactory = AiTranslationStrategy Function(CliOptions options);

/// The default factory: OpenAI (or a compatible endpoint) or the offline mock.
AiTranslationStrategy defaultStrategyFactory(CliOptions options) => switch (options.provider) {
  AiStrategyIds.mock => const MockTranslationStrategy(),
  _ => OpenAiTranslationStrategy(
    OpenAiRemoteDataSource(http.Client()),
    model: options.model,
    endpoint: options.endpoint,
  ),
};

/// Headless translation of an ARB folder.
///
/// Only locale files the run changed are written, and only the keys it changed: see
/// [ArbLocaleFile]. The base template is never written; translating does not change it.
class ArbTranslateCommand {
  ArbTranslateCommand({required this.out, required this.err, this.strategyFactory = defaultStrategyFactory});

  final StringSink out;
  final StringSink err;
  final StrategyFactory strategyFactory;
  final ArbFileDataSource _files = ArbFileDataSource();

  Future<int> run(CliOptions options) async {
    try {
      return await _run(options);
    } on CliUsageException catch (e) {
      err.writeln(e.message);
      return CliExitCode.usage;
    }
  }

  Future<int> _run(CliOptions options) async {
    final directory = options.directory;
    if (!Directory(directory).existsSync()) throw CliUsageException('Folder not found: $directory');

    final (baseLocale, locales, loaded, prefix) = await LoadArbFolder(TranslationRepositoryImpl(_files))(directory);
    final baseFile = File('$directory/$prefix$baseLocale.arb');
    if (!baseFile.existsSync()) throw CliUsageException('Template not found: ${baseFile.path}');
    final baseKeys = {
      for (final key in (await _files.readArb(baseFile)).keys)
        if (!key.startsWith('@')) key,
    };

    final targets =
        options.locales ??
        [
          for (final l in locales)
            if (l != baseLocale) l,
        ];
    if (targets.contains(baseLocale)) {
      throw CliUsageException('"$baseLocale" is the template locale; it is not translated.');
    }
    final unknownKeys = options.keys?.difference(baseKeys) ?? const <String>{};
    if (unknownKeys.isNotEmpty) throw CliUsageException('Not in the template: ${unknownKeys.join(', ')}');
    if (options.provider == AiStrategyIds.openAi && !options.dryRun && options.apiKey == null) {
      throw const CliUsageException('No API key: pass --api-key or set OPENAI_API_KEY.');
    }
    final glossary = _readGlossary(options.glossaryFile);

    final entries = [...loaded];
    final files = <String, ArbLocaleFile>{};
    ArbLocaleFile fileOf(String locale) =>
        files.putIfAbsent(locale, () => ArbLocaleFile.open(File('$directory/$prefix$locale.arb'), locale: locale));

    if (options.removeOrphans) {
      _removeOrphans(entries, baseKeys, [
        for (final l in locales)
          if (l != baseLocale) fileOf(l),
      ]);
    }

    for (final target in targets.where((t) => !locales.contains(t))) {
      out.writeln('$target: no file yet; it is created once a key is translated.');
    }

    var failures = 0;
    final strategy = options.dryRun ? null : strategyFactory(options);
    for (final target in targets) {
      failures += await _translateLocale(
        target: target,
        baseLocale: baseLocale,
        entries: entries,
        file: fileOf(target),
        options: options,
        strategy: strategy,
        glossary: glossary,
      );
    }

    await _write(files.values, options);
    if (failures > 0) {
      err.writeln('$failures translation(s) failed; those cells were left unchanged.');
      return CliExitCode.partialFailure;
    }
    return CliExitCode.ok;
  }

  void _removeOrphans(List<TranslationEntry> entries, Set<String> baseKeys, List<ArbLocaleFile> localeFiles) {
    final orphans = TranslationCells.orphanKeys(entries: entries, baseKeys: baseKeys).toSet();
    if (orphans.isEmpty) {
      out.writeln('Orphans: none.');
      return;
    }
    out.writeln('Orphans: removing ${orphans.length} key(s): ${orphans.join(', ')}');
    for (final file in localeFiles) {
      orphans.forEach(file.remove);
    }
    entries.removeWhere((e) => orphans.contains(e.key));
  }

  /// Translates [target] in [entries] and in its [file]; returns the number of failed cells.
  Future<int> _translateLocale({
    required String target,
    required String baseLocale,
    required List<TranslationEntry> entries,
    required ArbLocaleFile file,
    required CliOptions options,
    required AiTranslationStrategy? strategy,
    required String? glossary,
  }) async {
    final candidates = [
      for (final e in TranslationCells.translationCandidates(
        entries: entries,
        baseLocale: baseLocale,
        targetLocale: target,
        onlyMissing: options.mode == TranslateMode.missing,
        staleCells: TranslationCells.staleCellsIn(entries, baseLocale),
      ))
        if (options.keys?.contains(e.key) ?? true) e,
    ];
    if (candidates.isEmpty) {
      out.writeln('$target: nothing to translate.');
      return 0;
    }
    if (strategy == null) {
      out.writeln('$target: would translate ${candidates.length} key(s): ${candidates.map((e) => e.key).join(', ')}');
      return 0;
    }

    out.writeln('$target: translating ${candidates.length} key(s) with ${options.provider}/${options.model}...');
    var failures = 0;
    var applied = 0;
    await BatchTranslationRunner(
      strategy: strategy,
      apiKey: options.apiKey ?? '',
      glossaryPrompt: glossary,
      batchSize: options.batchSize,
    ).run(
      candidates: candidates,
      baseLocale: baseLocale,
      targetLocale: target,
      onBatchTranslated: (batch, translations) {
        for (final candidate in batch) {
          final problem = _apply(entries, file, candidate.key, target, baseLocale, translations[candidate.key]);
          if (problem == null) {
            applied++;
          } else {
            failures++;
            err.writeln('$target/${candidate.key}: $problem');
          }
        }
      },
      onBatchFailed: (batch, error, _) {
        failures += batch.length;
        err.writeln('$target: a batch of ${batch.length} key(s) failed: $error');
      },
    );
    out.writeln('$target: $applied translated, $failures failed.');
    return failures;
  }

  /// Writes [text] for [key] into [entries] and [file]; returns why it was rejected, or null.
  String? _apply(
    List<TranslationEntry> entries,
    ArbLocaleFile file,
    String key,
    String locale,
    String baseLocale,
    String? text,
  ) {
    if (text == null || text.trim().isEmpty) return 'no translation received';
    final index = entries.indexWhere((e) => e.key == key);
    final entry = entries[index];
    final english = extractPlaceholdersFromText(entry.values[baseLocale] ?? '');
    if (!placeholdersMatch(english: english, target: extractPlaceholdersFromText(text))) {
      return 'placeholders differ from the template, translation rejected: "$text"';
    }
    final oldText = entry.values[locale] ?? '';
    entries[index] = TranslationCells.trackSourceHashes(
      entry.copyWith(values: {...entry.values, locale: text}),
      baseLocale: baseLocale,
      locale: locale,
      oldText: oldText,
    );
    file.setTranslation(key, text, sourceHash: entries[index].sourceHashes[locale]);
    return null;
  }

  Future<void> _write(Iterable<ArbLocaleFile> files, CliOptions options) async {
    final changed = files.where((f) => f.isChanged).toList()..sort((a, b) => a.file.path.compareTo(b.file.path));
    if (changed.isEmpty) {
      out.writeln('No files changed.');
      return;
    }
    final names = changed.map((f) => p.basename(f.file.path)).join(', ');
    if (options.dryRun) {
      out.writeln('Dry run: would write $names');
      return;
    }
    for (final file in changed) {
      await file.save();
    }
    out.writeln('Wrote $names');
  }

  String? _readGlossary(String? path) {
    if (path == null) return null;
    final file = File(path);
    if (!file.existsSync()) throw CliUsageException('Glossary file not found: $path');
    try {
      return file.readAsStringSync();
    } on FileSystemException catch (e) {
      throw CliUsageException('Glossary file is not UTF-8 text or cannot be read: $path (${e.message})');
    }
  }
}
