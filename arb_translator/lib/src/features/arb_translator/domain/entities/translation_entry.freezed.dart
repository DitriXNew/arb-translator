// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'translation_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TranslationEntry {

 String get key; EntryMetadata get meta; Map<String, String> get values;
/// Create a copy of TranslationEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranslationEntryCopyWith<TranslationEntry> get copyWith => _$TranslationEntryCopyWithImpl<TranslationEntry>(this as TranslationEntry, _$identity);

  /// Serializes this TranslationEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranslationEntry&&(identical(other.key, key) || other.key == key)&&(identical(other.meta, meta) || other.meta == meta)&&const DeepCollectionEquality().equals(other.values, values));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,meta,const DeepCollectionEquality().hash(values));

@override
String toString() {
  return 'TranslationEntry(key: $key, meta: $meta, values: $values)';
}


}

/// @nodoc
abstract mixin class $TranslationEntryCopyWith<$Res>  {
  factory $TranslationEntryCopyWith(TranslationEntry value, $Res Function(TranslationEntry) _then) = _$TranslationEntryCopyWithImpl;
@useResult
$Res call({
 String key, EntryMetadata meta, Map<String, String> values
});


$EntryMetadataCopyWith<$Res> get meta;

}
/// @nodoc
class _$TranslationEntryCopyWithImpl<$Res>
    implements $TranslationEntryCopyWith<$Res> {
  _$TranslationEntryCopyWithImpl(this._self, this._then);

  final TranslationEntry _self;
  final $Res Function(TranslationEntry) _then;

/// Create a copy of TranslationEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? meta = null,Object? values = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as EntryMetadata,values: null == values ? _self.values : values // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}
/// Create a copy of TranslationEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntryMetadataCopyWith<$Res> get meta {
  
  return $EntryMetadataCopyWith<$Res>(_self.meta, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}


/// Adds pattern-matching-related methods to [TranslationEntry].
extension TranslationEntryPatterns on TranslationEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TranslationEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TranslationEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TranslationEntry value)  $default,){
final _that = this;
switch (_that) {
case _TranslationEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TranslationEntry value)?  $default,){
final _that = this;
switch (_that) {
case _TranslationEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  EntryMetadata meta,  Map<String, String> values)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranslationEntry() when $default != null:
return $default(_that.key,_that.meta,_that.values);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  EntryMetadata meta,  Map<String, String> values)  $default,) {final _that = this;
switch (_that) {
case _TranslationEntry():
return $default(_that.key,_that.meta,_that.values);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  EntryMetadata meta,  Map<String, String> values)?  $default,) {final _that = this;
switch (_that) {
case _TranslationEntry() when $default != null:
return $default(_that.key,_that.meta,_that.values);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TranslationEntry implements TranslationEntry {
  const _TranslationEntry({required this.key, this.meta = const EntryMetadata(), final  Map<String, String> values = const <String, String>{}}): _values = values;
  factory _TranslationEntry.fromJson(Map<String, dynamic> json) => _$TranslationEntryFromJson(json);

@override final  String key;
@override@JsonKey() final  EntryMetadata meta;
 final  Map<String, String> _values;
@override@JsonKey() Map<String, String> get values {
  if (_values is EqualUnmodifiableMapView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_values);
}


/// Create a copy of TranslationEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranslationEntryCopyWith<_TranslationEntry> get copyWith => __$TranslationEntryCopyWithImpl<_TranslationEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TranslationEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranslationEntry&&(identical(other.key, key) || other.key == key)&&(identical(other.meta, meta) || other.meta == meta)&&const DeepCollectionEquality().equals(other._values, _values));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,meta,const DeepCollectionEquality().hash(_values));

@override
String toString() {
  return 'TranslationEntry(key: $key, meta: $meta, values: $values)';
}


}

/// @nodoc
abstract mixin class _$TranslationEntryCopyWith<$Res> implements $TranslationEntryCopyWith<$Res> {
  factory _$TranslationEntryCopyWith(_TranslationEntry value, $Res Function(_TranslationEntry) _then) = __$TranslationEntryCopyWithImpl;
@override @useResult
$Res call({
 String key, EntryMetadata meta, Map<String, String> values
});


@override $EntryMetadataCopyWith<$Res> get meta;

}
/// @nodoc
class __$TranslationEntryCopyWithImpl<$Res>
    implements _$TranslationEntryCopyWith<$Res> {
  __$TranslationEntryCopyWithImpl(this._self, this._then);

  final _TranslationEntry _self;
  final $Res Function(_TranslationEntry) _then;

/// Create a copy of TranslationEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? meta = null,Object? values = null,}) {
  return _then(_TranslationEntry(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as EntryMetadata,values: null == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

/// Create a copy of TranslationEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntryMetadataCopyWith<$Res> get meta {
  
  return $EntryMetadataCopyWith<$Res>(_self.meta, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}

// dart format on
