import 'package:freezed_annotation/freezed_annotation.dart';

part 'entry_metadata.freezed.dart';
part 'entry_metadata.g.dart';

@freezed
abstract class EntryMetadata with _$EntryMetadata {
  const factory EntryMetadata({
    String? description,
    @Default(<String>{}) Set<String> placeholders,
    String? sourceHash,
  }) = _EntryMetadata;

  factory EntryMetadata.fromJson(Map<String, dynamic> json) => _$EntryMetadataFromJson(json);
}
