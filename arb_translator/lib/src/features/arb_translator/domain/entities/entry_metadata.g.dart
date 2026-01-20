// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EntryMetadata _$EntryMetadataFromJson(Map<String, dynamic> json) => _EntryMetadata(
  description: json['description'] as String?,
  placeholders: (json['placeholders'] as List<dynamic>?)?.map((e) => e as String).toSet() ?? const <String>{},
  sourceHash: json['sourceHash'] as String?,
);

Map<String, dynamic> _$EntryMetadataToJson(_EntryMetadata instance) => <String, dynamic>{
  'description': instance.description,
  'placeholders': instance.placeholders.toList(),
  'sourceHash': instance.sourceHash,
};
