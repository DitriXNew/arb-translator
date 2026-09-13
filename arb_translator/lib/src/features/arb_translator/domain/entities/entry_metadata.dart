import 'package:freezed_annotation/freezed_annotation.dart';

part 'entry_metadata.freezed.dart';
part 'entry_metadata.g.dart';

@freezed
abstract class EntryMetadata with _$EntryMetadata {
  /// ARB `@key` metadata.
  ///
  /// [placeholders] maps each placeholder name to its full ARB attribute map
  /// (`type`, `format`, `example`, `optionalParameters`, ...). The attributes
  /// must round-trip verbatim: `gen-l10n` reads placeholder types from the
  /// template only, so dropping `type` silently degrades a generated `int`
  /// parameter to `Object` and dropping `format` disables NumberFormat /
  /// DateFormat in every locale at once. An empty attribute map is a
  /// placeholder that genuinely carries no attributes.
  const factory EntryMetadata({
    String? description,
    @Default(<String, Map<String, dynamic>>{}) Map<String, Map<String, dynamic>> placeholders,
    String? sourceHash,
  }) = _EntryMetadata;

  factory EntryMetadata.fromJson(Map<String, dynamic> json) => _$EntryMetadataFromJson(json);
}
