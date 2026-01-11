// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entry_metadata.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EntryMetadata {

 String? get description; Set<String> get placeholders; String? get sourceHash;
/// Create a copy of EntryMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntryMetadataCopyWith<EntryMetadata> get copyWith => _$EntryMetadataCopyWithImpl<EntryMetadata>(this as EntryMetadata, _$identity);

  /// Serializes this EntryMetadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EntryMetadata&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.placeholders, placeholders)&&(identical(other.sourceHash, sourceHash) || other.sourceHash == sourceHash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,description,const DeepCollectionEquality().hash(placeholders),sourceHash);

@override
String toString() {
  return 'EntryMetadata(description: $description, placeholders: $placeholders, sourceHash: $sourceHash)';
}


}

/// @nodoc
abstract mixin class $EntryMetadataCopyWith<$Res>  {
  factory $EntryMetadataCopyWith(EntryMetadata value, $Res Function(EntryMetadata) _then) = _$EntryMetadataCopyWithImpl;
@useResult
$Res call({
 String? description, Set<String> placeholders, String? sourceHash
});




}
/// @nodoc
class _$EntryMetadataCopyWithImpl<$Res>
    implements $EntryMetadataCopyWith<$Res> {
  _$EntryMetadataCopyWithImpl(this._self, this._then);

  final EntryMetadata _self;
  final $Res Function(EntryMetadata) _then;

/// Create a copy of EntryMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? description = freezed,Object? placeholders = null,Object? sourceHash = freezed,}) {
  return _then(_self.copyWith(
description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,placeholders: null == placeholders ? _self.placeholders : placeholders // ignore: cast_nullable_to_non_nullable
as Set<String>,sourceHash: freezed == sourceHash ? _self.sourceHash : sourceHash // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EntryMetadata].
extension EntryMetadataPatterns on EntryMetadata {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EntryMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EntryMetadata() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EntryMetadata value)  $default,){
final _that = this;
switch (_that) {
case _EntryMetadata():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EntryMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _EntryMetadata() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? description,  Set<String> placeholders,  String? sourceHash)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EntryMetadata() when $default != null:
return $default(_that.description,_that.placeholders,_that.sourceHash);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? description,  Set<String> placeholders,  String? sourceHash)  $default,) {final _that = this;
switch (_that) {
case _EntryMetadata():
return $default(_that.description,_that.placeholders,_that.sourceHash);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? description,  Set<String> placeholders,  String? sourceHash)?  $default,) {final _that = this;
switch (_that) {
case _EntryMetadata() when $default != null:
return $default(_that.description,_that.placeholders,_that.sourceHash);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EntryMetadata implements EntryMetadata {
  const _EntryMetadata({this.description, final  Set<String> placeholders = const <String>{}, this.sourceHash}): _placeholders = placeholders;
  factory _EntryMetadata.fromJson(Map<String, dynamic> json) => _$EntryMetadataFromJson(json);

@override final  String? description;
 final  Set<String> _placeholders;
@override@JsonKey() Set<String> get placeholders {
  if (_placeholders is EqualUnmodifiableSetView) return _placeholders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_placeholders);
}

@override final  String? sourceHash;

/// Create a copy of EntryMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntryMetadataCopyWith<_EntryMetadata> get copyWith => __$EntryMetadataCopyWithImpl<_EntryMetadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EntryMetadataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EntryMetadata&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._placeholders, _placeholders)&&(identical(other.sourceHash, sourceHash) || other.sourceHash == sourceHash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,description,const DeepCollectionEquality().hash(_placeholders),sourceHash);

@override
String toString() {
  return 'EntryMetadata(description: $description, placeholders: $placeholders, sourceHash: $sourceHash)';
}


}

/// @nodoc
abstract mixin class _$EntryMetadataCopyWith<$Res> implements $EntryMetadataCopyWith<$Res> {
  factory _$EntryMetadataCopyWith(_EntryMetadata value, $Res Function(_EntryMetadata) _then) = __$EntryMetadataCopyWithImpl;
@override @useResult
$Res call({
 String? description, Set<String> placeholders, String? sourceHash
});




}
/// @nodoc
class __$EntryMetadataCopyWithImpl<$Res>
    implements _$EntryMetadataCopyWith<$Res> {
  __$EntryMetadataCopyWithImpl(this._self, this._then);

  final _EntryMetadata _self;
  final $Res Function(_EntryMetadata) _then;

/// Create a copy of EntryMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? description = freezed,Object? placeholders = null,Object? sourceHash = freezed,}) {
  return _then(_EntryMetadata(
description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,placeholders: null == placeholders ? _self._placeholders : placeholders // ignore: cast_nullable_to_non_nullable
as Set<String>,sourceHash: freezed == sourceHash ? _self.sourceHash : sourceHash // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
