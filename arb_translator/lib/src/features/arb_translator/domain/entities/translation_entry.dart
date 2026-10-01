import 'package:arb_translator/src/features/arb_translator/domain/entities/entry_metadata.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'translation_entry.freezed.dart';
part 'translation_entry.g.dart';

@freezed
abstract class TranslationEntry with _$TranslationEntry {
  /// One ARB key across every locale.
  ///
  /// [sourceHashes] maps each non-base locale to the hash of the base-locale
  /// text its translation was made from. Tracked per locale so retranslating
  /// one locale does not mark the others as up to date.
  const factory TranslationEntry({
    required String key,
    @Default(EntryMetadata()) EntryMetadata meta,
    @Default(<String, String>{}) Map<String, String> values,
    @Default(<String, String>{}) Map<String, String> sourceHashes,
  }) = _TranslationEntry;

  factory TranslationEntry.fromJson(Map<String, dynamic> json) => _$TranslationEntryFromJson(json);
}
