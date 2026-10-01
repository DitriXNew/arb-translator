import 'dart:convert';
import 'dart:io';

import 'package:arb_translator/src/core/utils/hash_utils.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Staleness is tracked per (key, locale): retranslating one locale must not
/// clear the stale flag of the other locales, in memory or across save/reload.
void main() {
  late Directory tempDir;
  final oldHash = HashUtils.computeSourceHash('Old text');
  final newHash = HashUtils.computeSourceHash('New text');

  Future<void> writeArb(String locale, Map<String, dynamic> data) =>
      File(p.join(tempDir.path, 'app_$locale.arb')).writeAsString(json.encode({'@@locale': locale, ...data}));

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('arb_stale_per_locale');
    await writeArb('en', {
      'msg': 'New text',
      '@msg': {'sourceHash': newHash},
    });
    for (final (locale, text) in [('de', 'Alter Text'), ('fr', 'Ancien texte'), ('es', 'Texto antiguo')]) {
      await writeArb(locale, {
        'msg': text,
        '@msg': {'sourceHash': oldHash},
      });
    }
  });

  tearDown(() async {
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  ProjectController controllerFor(ProviderContainer c) => c.read(projectControllerProvider.notifier);

  test('reads staleness from each locale file, not from the EN hash', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await controllerFor(container).loadFolder(tempDir.path);

    expect(container.read(projectControllerProvider).staleCells, {('msg', 'de'), ('msg', 'fr'), ('msg', 'es')});
  });

  test('translating one locale keeps the others stale, also after save and reload', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = controllerFor(container);
    await controller.loadFolder(tempDir.path);

    controller.updateCell(key: 'msg', locale: 'de', text: 'Neuer Text');
    expect(container.read(projectControllerProvider).staleCells, {('msg', 'fr'), ('msg', 'es')});

    await controller.saveAll();
    final deMeta = json.decode(File(p.join(tempDir.path, 'app_de.arb')).readAsStringSync())['@msg'];
    final frMeta = json.decode(File(p.join(tempDir.path, 'app_fr.arb')).readAsStringSync())['@msg'];
    expect(deMeta['sourceHash'], newHash);
    expect(frMeta['sourceHash'], oldHash);

    final reloaded = ProviderContainer();
    addTearDown(reloaded.dispose);
    await controllerFor(reloaded).loadFolder(tempDir.path);
    expect(reloaded.read(projectControllerProvider).staleCells, {('msg', 'fr'), ('msg', 'es')});
  });

  test('editing the base text marks translations stale; reverting it clears them', () async {
    for (final locale in ['de', 'fr', 'es']) {
      await writeArb(locale, {
        'msg': 'x',
        '@msg': {'sourceHash': newHash},
      });
    }
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = controllerFor(container);
    await controller.loadFolder(tempDir.path);
    expect(container.read(projectControllerProvider).staleCells, isEmpty);

    controller.updateCell(key: 'msg', locale: 'en', text: 'Edited text');
    expect(container.read(projectControllerProvider).staleCells, {('msg', 'de'), ('msg', 'fr'), ('msg', 'es')});

    controller.updateCell(key: 'msg', locale: 'en', text: 'New text');
    expect(container.read(projectControllerProvider).staleCells, isEmpty);
  });
}
