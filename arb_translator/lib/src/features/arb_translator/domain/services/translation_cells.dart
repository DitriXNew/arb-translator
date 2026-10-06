import 'package:arb_translator/src/core/utils/hash_utils.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';

/// Pure rules for translation cells, shared by the desktop UI and the command line.
///
/// A cell is a `(key, locale)` pair. Nothing here touches files, providers or the network.
class TranslationCells {
  /// Non-base cells of [entry] whose translation was made from a different base text.
  ///
  /// A cell without a recorded source hash is never stale: there is nothing to compare.
  static Iterable<(String, String)> staleCellsOf(TranslationEntry entry, String baseLocale) sync* {
    final sourceText = entry.values[baseLocale] ?? '';
    if (sourceText.isEmpty || entry.sourceHashes.isEmpty) return;
    final currentHash = HashUtils.computeSourceHash(sourceText);
    for (final MapEntry(key: locale, value: hash) in entry.sourceHashes.entries) {
      if (locale == baseLocale || (entry.values[locale] ?? '').isEmpty) continue;
      if (hash != currentHash) yield (entry.key, locale);
    }
  }

  /// Stale cells across [entries].
  static Set<(String, String)> staleCellsIn(Iterable<TranslationEntry> entries, String baseLocale) => {
    for (final entry in entries) ...staleCellsOf(entry, baseLocale),
  };

  /// Keeps [TranslationEntry.sourceHashes] in step with an edit of [locale].
  ///
  /// [entry] already holds the new text; [oldText] is what [locale] held before.
  /// A translation edit records the current base hash for that locale only. A base
  /// edit pins every translation without a recorded hash to the previous base text,
  /// so the change shows up as stale instead of being silently accepted.
  static TranslationEntry trackSourceHashes(
    TranslationEntry entry, {
    required String baseLocale,
    required String locale,
    required String oldText,
  }) {
    final hashes = Map<String, String>.from(entry.sourceHashes);
    if (locale != baseLocale) {
      final sourceText = entry.values[baseLocale] ?? '';
      if ((entry.values[locale] ?? '').isEmpty || sourceText.isEmpty) {
        hashes.remove(locale);
      } else {
        hashes[locale] = HashUtils.computeSourceHash(sourceText);
      }
    } else if (oldText.isNotEmpty) {
      final oldHash = HashUtils.computeSourceHash(oldText);
      for (final MapEntry(key: l, value: text) in entry.values.entries) {
        if (l != baseLocale && text.isNotEmpty) hashes.putIfAbsent(l, () => oldHash);
      }
    }
    return entry.copyWith(sourceHashes: hashes);
  }

  /// Entries to send for translation into [targetLocale].
  ///
  /// Entries without base text are never candidates. With [onlyMissing] an entry qualifies
  /// when its target cell is empty or stale; otherwise every entry with base text does.
  static List<TranslationEntry> translationCandidates({
    required List<TranslationEntry> entries,
    required String baseLocale,
    required String targetLocale,
    required bool onlyMissing,
    required Set<(String, String)> staleCells,
  }) => [
    for (final e in entries)
      if ((e.values[baseLocale] ?? '').isNotEmpty)
        if (!onlyMissing || (e.values[targetLocale] ?? '').isEmpty || staleCells.contains((e.key, targetLocale))) e,
  ];

  /// Keys of [entries] that the base locale file does not declare, in entry order.
  ///
  /// Only true orphans: a key present in the base file with an empty value is not one.
  static List<String> orphanKeys({required List<TranslationEntry> entries, required Set<String> baseKeys}) => [
    for (final e in entries)
      if (!baseKeys.contains(e.key)) e.key,
  ];
}
