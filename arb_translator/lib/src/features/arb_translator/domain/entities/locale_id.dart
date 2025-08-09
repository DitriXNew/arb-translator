import 'package:freezed_annotation/freezed_annotation.dart';

part 'locale_id.freezed.dart';

@freezed
abstract class LocaleId with _$LocaleId {
  const factory LocaleId(String code) = _LocaleId;
}
