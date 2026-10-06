import 'dart:convert';
import 'dart:io';

import 'package:arb_translator/src/cli/arb_translate_command.dart';
import 'package:arb_translator/src/cli/cli_options.dart';
import 'package:arb_translator/src/core/utils/hash_utils.dart';
import 'package:arb_translator/src/features/arb_translator/data/ai/mock_strategy.dart';
import 'package:arb_translator/src/features/arb_translator/domain/ai/ai_translation_strategy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Answers every key with fixed text, ignoring the source.
class _FixedStrategy extends MockTranslationStrategy {
  const _FixedStrategy(this.text);
  final String text;

  @override
  Future<Map<String, String>> translateBatch({
    required String apiKey,
    required List<BatchTranslationItem> items,
    required String targetLocale,
    String? glossaryPrompt,
  }) async => {for (final item in items) item.key: text};
}

/// Answers from [answers] and throws for keys in [failing]; records each glossary it was given.
class _ScriptedStrategy extends MockTranslationStrategy {
  _ScriptedStrategy({this.answers = const {}, this.failing = const {}});
  final Map<String, String> answers;
  final Set<String> failing;
  final glossaries = <String?>[];

  @override
  Future<Map<String, String>> translateBatch({
    required String apiKey,
    required List<BatchTranslationItem> items,
    required String targetLocale,
    String? glossaryPrompt,
  }) async {
    glossaries.add(glossaryPrompt);
    if (items.any((i) => failing.contains(i.key))) throw StateError('provider failed');
    return {for (final item in items) item.key: answers[item.key] ?? '${item.text}<$targetLocale>'};
  }
}

void main() {
  late Directory dir;
  late StringBuffer out;
  late StringBuffer err;

  // Hand-maintained template: unsorted keys and a trailing newline the tool must not touch.
  final enSource =
      '${const JsonEncoder.withIndent('  ').convert({
        '@@locale': 'en',
        'zeta': 'Last word',
        '@zeta': {'description': 'z'},
        'greeting': 'Hello {name}',
        '@greeting': {
          'description': 'g',
          'placeholders': {'name': {}},
        },
        'alpha': 'First word',
        '@alpha': {'description': 'a'},
      })}\n';

  File arb(String locale) => File(p.join(dir.path, 'app_$locale.arb'));
  Map<String, dynamic> read(String locale) => json.decode(arb(locale).readAsStringSync()) as Map<String, dynamic>;

  Future<int> runCli(List<String> args, {AiTranslationStrategy strategy = const MockTranslationStrategy()}) async {
    final options = CliOptions.parse(['--dir', dir.path, '--provider', 'mock', ...args])!;
    return ArbTranslateCommand(out: out, err: err, strategyFactory: (_) => strategy).run(options);
  }

  setUp(() {
    dir = Directory.systemTemp.createTempSync('arb_cli_test');
    out = StringBuffer();
    err = StringBuffer();
    arb('en').writeAsStringSync(enSource);
    arb('de').writeAsStringSync(
      json.encode({
        '@@locale': 'de',
        'alpha': 'Erstes Wort',
        '@alpha': {'sourceHash': HashUtils.computeSourceHash('First word')},
        'orphan': 'Verwaist',
        '@orphan': {'sourceHash': 'x'},
      }),
    );
    arb('fr').writeAsStringSync(
      json.encode({
        '@@locale': 'fr',
        'alpha': 'Premier mot',
        '@alpha': {'sourceHash': HashUtils.computeSourceHash('First word')},
        'greeting': 'Bonjour {name}',
        '@greeting': {'sourceHash': HashUtils.computeSourceHash('Hello {name}')},
        'zeta': 'Dernier mot',
        '@zeta': {'sourceHash': HashUtils.computeSourceHash('Last word')},
      }),
    );
  });

  tearDown(() => dir.deleteSync(recursive: true));

  test('translates only the missing keys of the chosen locale and writes only that file', () async {
    final frBefore = arb('fr').readAsStringSync();

    final code = await runCli(['--locales', 'de']);

    expect(code, CliExitCode.ok, reason: '$err');
    final de = read('de');
    expect(de['alpha'], 'Erstes Wort', reason: 'an up-to-date translation is kept');
    expect(de['greeting'], 'Hello {name}<de>');
    expect(de['zeta'], 'Last word<de>');
    expect((de['@zeta'] as Map)['sourceHash'], HashUtils.computeSourceHash('Last word'));
    expect(arb('en').readAsStringSync(), enSource, reason: 'the template is never rewritten');
    expect(arb('fr').readAsStringSync(), frBefore, reason: 'a locale not asked for is not written');
  });

  test('without --locales every non-template locale is a target', () async {
    arb('fr').writeAsStringSync(json.encode({'@@locale': 'fr', 'alpha': 'Premier mot'}));

    expect(await runCli([]), CliExitCode.ok, reason: '$err');

    expect(read('de')['zeta'], 'Last word<de>');
    expect(read('fr')['zeta'], 'Last word<fr>');
  });

  test('a stale translation is retranslated in missing mode', () async {
    arb('en').writeAsStringSync(enSource.replaceFirst('First word', 'Opening word'));

    expect(await runCli(['--locales', 'de', '--keys', 'alpha']), CliExitCode.ok, reason: '$err');

    expect(read('de')['alpha'], 'Opening word<de>');
  });

  test('mode all overwrites existing translations', () async {
    expect(await runCli(['--locales', 'fr', '--mode', 'all']), CliExitCode.ok, reason: '$err');
    expect(read('fr')['alpha'], 'First word<fr>');
  });

  test('--keys limits the run to those keys', () async {
    expect(await runCli(['--locales', 'de', '--keys', 'zeta']), CliExitCode.ok, reason: '$err');
    final de = read('de');
    expect(de['zeta'], 'Last word<de>');
    expect(de.containsKey('greeting'), isFalse);
  });

  test('orphans survive unless --remove-orphans is given', () async {
    await runCli(['--locales', 'de']);
    expect(read('de').containsKey('orphan'), isTrue);

    expect(await runCli(['--locales', 'fr', '--remove-orphans']), CliExitCode.ok, reason: '$err');
    final de = read('de');
    expect(de.containsKey('orphan'), isFalse, reason: 'orphan removal writes every locale that held one');
    expect(de.containsKey('@orphan'), isFalse);
    expect(de['alpha'], 'Erstes Wort', reason: 'only the orphan goes');
    expect(de['zeta'], 'Last word<de>');
  });

  test('an orphan with an empty value is removed too', () async {
    arb('de').writeAsStringSync(json.encode({'@@locale': 'de', 'alpha': 'Erstes Wort', 'gone': ''}));

    expect(await runCli(['--locales', 'fr', '--remove-orphans']), CliExitCode.ok, reason: '$err');

    expect(read('de').containsKey('gone'), isFalse);
    expect(read('de')['alpha'], 'Erstes Wort');
  });

  test('editing one key keeps everything else in the locale file', () async {
    arb('en').writeAsStringSync(enSource.replaceFirst('"alpha"', '"blank": "",\n  "alpha"'));
    arb('de').writeAsStringSync(
      json.encode({
        '@@locale': 'de',
        '@@x-generated-by': 'hand',
        'blank': '',
        'alpha': 'Erstes Wort',
        '@alpha': {'sourceHash': HashUtils.computeSourceHash('First word'), 'x-note': 'keep me'},
      }),
    );

    expect(await runCli(['--locales', 'de', '--keys', 'zeta']), CliExitCode.ok, reason: '$err');

    final de = read('de');
    expect(de['zeta'], 'Last word<de>');
    expect(de['@@x-generated-by'], 'hand');
    expect(de['blank'], '', reason: 'an explicitly empty key is not dropped');
    expect(de['@alpha'], {'sourceHash': HashUtils.computeSourceHash('First word'), 'x-note': 'keep me'});
  });

  test('a provider answer equal to the existing text writes nothing', () async {
    final frBefore = arb('fr').readAsStringSync();
    final echo = _ScriptedStrategy(
      answers: {'alpha': 'Premier mot', 'greeting': 'Bonjour {name}', 'zeta': 'Dernier mot'},
    );

    expect(await runCli(['--locales', 'fr', '--mode', 'all'], strategy: echo), CliExitCode.ok, reason: '$err');

    expect(arb('fr').readAsStringSync(), frBefore);
  });

  test('a failed batch does not lose the batches that succeeded', () async {
    final strategy = _ScriptedStrategy(failing: {'greeting'});

    final code = await runCli(['--locales', 'de', '--batch-size', '1'], strategy: strategy);

    expect(code, CliExitCode.partialFailure);
    final de = read('de');
    expect(de['zeta'], 'Last word<de>');
    expect(de.containsKey('greeting'), isFalse);
    expect(err.toString(), contains('1 translation(s) failed'));
  });

  test('the glossary file reaches the provider', () async {
    final glossary = File(p.join(dir.path, 'glossary.txt'))..writeAsStringSync('Größe stays Größe');
    final strategy = _ScriptedStrategy();

    expect(
      await runCli(['--locales', 'de', '--glossary-file', glossary.path], strategy: strategy),
      CliExitCode.ok,
      reason: '$err',
    );

    expect(strategy.glossaries, ['Größe stays Größe']);
  });

  test('a translation that renames a plural argument is rejected', () async {
    arb('en').writeAsStringSync(
      json.encode({'@@locale': 'en', 'files': '{count, plural, =1{One segment} other{{count} segments}}'}),
    );
    final strategy = _ScriptedStrategy(answers: {'files': '{anzahl, plural, =1{Ein Segment} other{{count} Segmente}}'});

    expect(await runCli(['--locales', 'de'], strategy: strategy), CliExitCode.partialFailure);
    expect(read('de').containsKey('files'), isFalse);
  });

  test('a translated one-word plural case is accepted', () async {
    arb('en').writeAsStringSync(
      json.encode({'@@locale': 'en', 'files': '{count, plural, =1{segment} other{{count} segments}}'}),
    );
    final strategy = _ScriptedStrategy(answers: {'files': '{count, plural, =1{Segment} other{{count} Segmente}}'});

    expect(await runCli(['--locales', 'de'], strategy: strategy), CliExitCode.ok, reason: '$err');
    expect(read('de')['files'], '{count, plural, =1{Segment} other{{count} Segmente}}');
  });

  test('a translation with an unclosed plural is rejected', () async {
    arb('en').writeAsStringSync(json.encode({'@@locale': 'en', 'files': '{count, plural, one{One} other{Many}}'}));
    final strategy = _ScriptedStrategy(answers: {'files': '{count, plural, one{Eins} other{Viele}'});

    expect(await runCli(['--locales', 'de'], strategy: strategy), CliExitCode.partialFailure);
    expect(read('de').containsKey('files'), isFalse);
  });

  test('a locale file not named <prefix><locale>.arb is a usage error, and nothing is written', () async {
    arb('de').renameSync(p.join(dir.path, 'legacy_de.arb'));

    expect(await runCli(['--locales', 'de', '--remove-orphans']), CliExitCode.usage);

    expect(err.toString(), contains('legacy_de.arb'));
    expect(arb('de').existsSync(), isFalse);
    expect(json.decode(File(p.join(dir.path, 'legacy_de.arb')).readAsStringSync()), containsPair('orphan', 'Verwaist'));
  });

  test('an .arb file whose name is not a locale is a usage error', () async {
    File(p.join(dir.path, 'app_notes.arb')).writeAsStringSync(json.encode({'alpha': 'note'}));

    expect(await runCli(['--locales', 'de']), CliExitCode.usage);
    expect(err.toString(), contains('app_notes.arb'));
  });

  test('an @@locale that is not a non-empty string is a usage error naming the file', () async {
    arb('fr').writeAsStringSync(json.encode({'@@locale': 7, 'alpha': 'Premier mot'}));
    expect(await runCli(['--locales', 'de']), CliExitCode.usage);
    expect(err.toString(), contains('app_fr.arb'));

    arb('fr').deleteSync();
    File(p.join(dir.path, 'app_.arb')).writeAsStringSync(json.encode({'@@locale': '', 'alpha': 'x'}));
    expect(await runCli([]), CliExitCode.usage);
    expect(err.toString(), contains('app_.arb'));
  });

  test('a locale file whose @@locale disagrees with its name is a usage error', () async {
    arb('fr').writeAsStringSync(json.encode({'@@locale': 'it', 'alpha': 'Primo'}));

    expect(await runCli(['--locales', 'de']), CliExitCode.usage);
    expect(err.toString(), contains('app_fr.arb'));
  });

  test('a dry run changes no file', () async {
    final before = {
      for (final l in ['en', 'de', 'fr']) l: arb(l).readAsStringSync(),
    };

    expect(await runCli(['--dry-run', '--remove-orphans']), CliExitCode.ok, reason: '$err');

    for (final l in before.keys) {
      expect(arb(l).readAsStringSync(), before[l], reason: '$l must be untouched');
    }
    expect(out.toString(), contains('de: would translate 2 key(s): greeting, zeta'));
  });

  test('a translation that loses a placeholder is rejected and the run reports failure', () async {
    final code = await runCli(['--locales', 'de', '--keys', 'greeting'], strategy: const _FixedStrategy('Hallo'));

    expect(code, CliExitCode.partialFailure);
    expect(read('de').containsKey('greeting'), isFalse);
    expect(err.toString(), contains('de/greeting: placeholders differ'));
  });

  test('a locale without a file gets one', () async {
    expect(await runCli(['--locales', 'it']), CliExitCode.ok, reason: '$err');
    final it = read('it');
    expect(it['@@locale'], 'it');
    expect(it['alpha'], 'First word<it>');
    expect(it['greeting'], 'Hello {name}<it>');
    expect(it['zeta'], 'Last word<it>');
    expect((it['@zeta'] as Map)['sourceHash'], HashUtils.computeSourceHash('Last word'));
  });

  test('a glossary that is not UTF-8 is a usage error, not a crash', () async {
    final glossary = File(p.join(dir.path, 'glossary.txt'))..writeAsBytesSync(latin1.encode('Einstellungen -> Größe'));

    final code = await runCli(['--locales', 'de', '--glossary-file', glossary.path]);

    expect(code, CliExitCode.usage);
    expect(err.toString(), contains('not UTF-8 text'));
  });

  test('the template locale and unknown keys are usage errors', () async {
    expect(await runCli(['--locales', 'en']), CliExitCode.usage);
    expect(await runCli(['--keys', 'nope']), CliExitCode.usage);
    expect(err.toString(), contains('Not in the template: nope'));
  });

  group('CliOptions', () {
    test('requires --dir', () {
      expect(() => CliOptions.parse([]), throwsA(isA<CliUsageException>()));
    });

    test('reads the API key from OPENAI_API_KEY unless --api-key is given', () {
      expect(CliOptions.parse(['-d', 'x'], environment: {'OPENAI_API_KEY': 'env'})!.apiKey, 'env');
      expect(
        CliOptions.parse(['-d', 'x', '--api-key', 'flag'], environment: {'OPENAI_API_KEY': 'env'})!.apiKey,
        'flag',
      );
    });

    test('rejects a non-positive batch size and an endpoint that is not a URL', () {
      expect(() => CliOptions.parse(['-d', 'x', '--batch-size', '0']), throwsA(isA<CliUsageException>()));
      expect(() => CliOptions.parse(['-d', 'x', '--endpoint', 'nope']), throwsA(isA<CliUsageException>()));
    });

    test('openai without a key is refused before any request', () async {
      final options = CliOptions.parse(['-d', dir.path, '--locales', 'de'])!;
      final code = await ArbTranslateCommand(
        out: out,
        err: err,
        strategyFactory: (_) => throw StateError('no strategy without a key'),
      ).run(options);
      expect(code, CliExitCode.usage);
      expect(err.toString(), contains('No API key'));
    });
  });
}
