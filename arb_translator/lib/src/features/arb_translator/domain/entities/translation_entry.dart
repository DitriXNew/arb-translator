import 'package:arb_translator/src/features/arb_translator/domain/entities/entry_metadata.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'translation_entry.freezed.dart';
part 'translation_entry.g.dart';

@freezed
abstract class TranslationEntry with _$TranslationEntry {
  const factory TranslationEntry({
    required String key,
    @Default(EntryMetadata()) EntryMetadata meta,
    @Default(<String, String>{}) Map<String, String> values,
  }) = _TranslationEntry;

  factory TranslationEntry.fromJson(Map<String, dynamic> json) => _$TranslationEntryFromJson(json);
}
