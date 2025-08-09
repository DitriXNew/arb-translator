// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'locale_id.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LocaleId {

 String get code;
/// Create a copy of LocaleId
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocaleIdCopyWith<LocaleId> get copyWith => _$LocaleIdCopyWithImpl<LocaleId>(this as LocaleId, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocaleId&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode => Object.hash(runtimeType,code);

@override
String toString() {
  return 'LocaleId(code: $code)';
}


}

/// @nodoc
abstract mixin class $LocaleIdCopyWith<$Res>  {
  factory $LocaleIdCopyWith(LocaleId value, $Res Function(LocaleId) _then) = _$LocaleIdCopyWithImpl;
@useResult
$Res call({
 String code
});




}
/// @nodoc
class _$LocaleIdCopyWithImpl<$Res>
    implements $LocaleIdCopyWith<$Res> {
  _$LocaleIdCopyWithImpl(this._self, this._then);

  final LocaleId _self;
  final $Res Function(LocaleId) _then;

/// Create a copy of LocaleId
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LocaleId].
extension LocaleIdPatterns on LocaleId {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocaleId value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocaleId() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocaleId value)  $default,){
final _that = this;
switch (_that) {
case _LocaleId():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocaleId value)?  $default,){
final _that = this;
switch (_that) {
case _LocaleId() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocaleId() when $default != null:
return $default(_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code)  $default,) {final _that = this;
switch (_that) {
case _LocaleId():
return $default(_that.code);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code)?  $default,) {final _that = this;
switch (_that) {
case _LocaleId() when $default != null:
return $default(_that.code);case _:
  return null;

}
}

}

/// @nodoc


class _LocaleId implements LocaleId {
  const _LocaleId(this.code);
  

@override final  String code;

/// Create a copy of LocaleId
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocaleIdCopyWith<_LocaleId> get copyWith => __$LocaleIdCopyWithImpl<_LocaleId>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocaleId&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode => Object.hash(runtimeType,code);

@override
String toString() {
  return 'LocaleId(code: $code)';
}


}

/// @nodoc
abstract mixin class _$LocaleIdCopyWith<$Res> implements $LocaleIdCopyWith<$Res> {
  factory _$LocaleIdCopyWith(_LocaleId value, $Res Function(_LocaleId) _then) = __$LocaleIdCopyWithImpl;
@override @useResult
$Res call({
 String code
});




}
/// @nodoc
class __$LocaleIdCopyWithImpl<$Res>
    implements _$LocaleIdCopyWith<$Res> {
  __$LocaleIdCopyWithImpl(this._self, this._then);

  final _LocaleId _self;
  final $Res Function(_LocaleId) _then;

/// Create a copy of LocaleId
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,}) {
  return _then(_LocaleId(
null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
