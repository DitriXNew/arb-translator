// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EntryMetadata _$EntryMetadataFromJson(Map<String, dynamic> json) =>
    _EntryMetadata(
      description: json['description'] as String?,
      placeholders:
          (json['placeholders'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as Map<String, dynamic>),
          ) ??
          const <String, Map<String, dynamic>>{},
      sourceHash: json['sourceHash'] as String?,
    );

Map<String, dynamic> _$EntryMetadataToJson(_EntryMetadata instance) =>
    <String, dynamic>{
      'description': instance.description,
      'placeholders': instance.placeholders,
      'sourceHash': instance.sourceHash,
    };
