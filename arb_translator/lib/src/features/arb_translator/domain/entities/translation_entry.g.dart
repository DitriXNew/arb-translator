// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TranslationEntry _$TranslationEntryFromJson(Map<String, dynamic> json) =>
    _TranslationEntry(
      key: json['key'] as String,
      meta: json['meta'] == null
          ? const EntryMetadata()
          : EntryMetadata.fromJson(json['meta'] as Map<String, dynamic>),
      values:
          (json['values'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const <String, String>{},
    );

Map<String, dynamic> _$TranslationEntryToJson(_TranslationEntry instance) =>
    <String, dynamic>{
      'key': instance.key,
      'meta': instance.meta,
      'values': instance.values,
    };
