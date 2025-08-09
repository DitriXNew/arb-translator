// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProjectState {

 String? get folderPath; String get baseLocale; List<String> get locales; List<TranslationEntry> get entries; Set<String> get baseLocaleKeys; Set<(String key, String locale)> get dirtyCells; Set<String> get dirtyLocales; Set<(String, String)> get errorCells; bool get hasUnsavedChanges; bool get showOnlyErrors; bool get showOnlyUntranslated; String get searchQuery; bool get isLoading; bool get isSaving; (String key, String locale)? get lastEditedCell; DateTime? get lastSavedAt;
/// Create a copy of ProjectState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectStateCopyWith<ProjectState> get copyWith => _$ProjectStateCopyWithImpl<ProjectState>(this as ProjectState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectState&&(identical(other.folderPath, folderPath) || other.folderPath == folderPath)&&(identical(other.baseLocale, baseLocale) || other.baseLocale == baseLocale)&&const DeepCollectionEquality().equals(other.locales, locales)&&const DeepCollectionEquality().equals(other.entries, entries)&&const DeepCollectionEquality().equals(other.baseLocaleKeys, baseLocaleKeys)&&const DeepCollectionEquality().equals(other.dirtyCells, dirtyCells)&&const DeepCollectionEquality().equals(other.dirtyLocales, dirtyLocales)&&const DeepCollectionEquality().equals(other.errorCells, errorCells)&&(identical(other.hasUnsavedChanges, hasUnsavedChanges) || other.hasUnsavedChanges == hasUnsavedChanges)&&(identical(other.showOnlyErrors, showOnlyErrors) || other.showOnlyErrors == showOnlyErrors)&&(identical(other.showOnlyUntranslated, showOnlyUntranslated) || other.showOnlyUntranslated == showOnlyUntranslated)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.lastEditedCell, lastEditedCell) || other.lastEditedCell == lastEditedCell)&&(identical(other.lastSavedAt, lastSavedAt) || other.lastSavedAt == lastSavedAt));
}


@override
int get hashCode => Object.hash(runtimeType,folderPath,baseLocale,const DeepCollectionEquality().hash(locales),const DeepCollectionEquality().hash(entries),const DeepCollectionEquality().hash(baseLocaleKeys),const DeepCollectionEquality().hash(dirtyCells),const DeepCollectionEquality().hash(dirtyLocales),const DeepCollectionEquality().hash(errorCells),hasUnsavedChanges,showOnlyErrors,showOnlyUntranslated,searchQuery,isLoading,isSaving,lastEditedCell,lastSavedAt);

@override
String toString() {
  return 'ProjectState(folderPath: $folderPath, baseLocale: $baseLocale, locales: $locales, entries: $entries, baseLocaleKeys: $baseLocaleKeys, dirtyCells: $dirtyCells, dirtyLocales: $dirtyLocales, errorCells: $errorCells, hasUnsavedChanges: $hasUnsavedChanges, showOnlyErrors: $showOnlyErrors, showOnlyUntranslated: $showOnlyUntranslated, searchQuery: $searchQuery, isLoading: $isLoading, isSaving: $isSaving, lastEditedCell: $lastEditedCell, lastSavedAt: $lastSavedAt)';
}


}

/// @nodoc
abstract mixin class $ProjectStateCopyWith<$Res>  {
  factory $ProjectStateCopyWith(ProjectState value, $Res Function(ProjectState) _then) = _$ProjectStateCopyWithImpl;
@useResult
$Res call({
 String? folderPath, String baseLocale, List<String> locales, List<TranslationEntry> entries, Set<String> baseLocaleKeys, Set<(String key, String locale)> dirtyCells, Set<String> dirtyLocales, Set<(String, String)> errorCells, bool hasUnsavedChanges, bool showOnlyErrors, bool showOnlyUntranslated, String searchQuery, bool isLoading, bool isSaving, (String key, String locale)? lastEditedCell, DateTime? lastSavedAt
});




}
/// @nodoc
class _$ProjectStateCopyWithImpl<$Res>
    implements $ProjectStateCopyWith<$Res> {
  _$ProjectStateCopyWithImpl(this._self, this._then);

  final ProjectState _self;
  final $Res Function(ProjectState) _then;

/// Create a copy of ProjectState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? folderPath = freezed,Object? baseLocale = null,Object? locales = null,Object? entries = null,Object? baseLocaleKeys = null,Object? dirtyCells = null,Object? dirtyLocales = null,Object? errorCells = null,Object? hasUnsavedChanges = null,Object? showOnlyErrors = null,Object? showOnlyUntranslated = null,Object? searchQuery = null,Object? isLoading = null,Object? isSaving = null,Object? lastEditedCell = freezed,Object? lastSavedAt = freezed,}) {
  return _then(_self.copyWith(
folderPath: freezed == folderPath ? _self.folderPath : folderPath // ignore: cast_nullable_to_non_nullable
as String?,baseLocale: null == baseLocale ? _self.baseLocale : baseLocale // ignore: cast_nullable_to_non_nullable
as String,locales: null == locales ? _self.locales : locales // ignore: cast_nullable_to_non_nullable
as List<String>,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<TranslationEntry>,baseLocaleKeys: null == baseLocaleKeys ? _self.baseLocaleKeys : baseLocaleKeys // ignore: cast_nullable_to_non_nullable
as Set<String>,dirtyCells: null == dirtyCells ? _self.dirtyCells : dirtyCells // ignore: cast_nullable_to_non_nullable
as Set<(String key, String locale)>,dirtyLocales: null == dirtyLocales ? _self.dirtyLocales : dirtyLocales // ignore: cast_nullable_to_non_nullable
as Set<String>,errorCells: null == errorCells ? _self.errorCells : errorCells // ignore: cast_nullable_to_non_nullable
as Set<(String, String)>,hasUnsavedChanges: null == hasUnsavedChanges ? _self.hasUnsavedChanges : hasUnsavedChanges // ignore: cast_nullable_to_non_nullable
as bool,showOnlyErrors: null == showOnlyErrors ? _self.showOnlyErrors : showOnlyErrors // ignore: cast_nullable_to_non_nullable
as bool,showOnlyUntranslated: null == showOnlyUntranslated ? _self.showOnlyUntranslated : showOnlyUntranslated // ignore: cast_nullable_to_non_nullable
as bool,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,lastEditedCell: freezed == lastEditedCell ? _self.lastEditedCell : lastEditedCell // ignore: cast_nullable_to_non_nullable
as (String key, String locale)?,lastSavedAt: freezed == lastSavedAt ? _self.lastSavedAt : lastSavedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectState].
extension ProjectStatePatterns on ProjectState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectState value)  $default,){
final _that = this;
switch (_that) {
case _ProjectState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectState value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? folderPath,  String baseLocale,  List<String> locales,  List<TranslationEntry> entries,  Set<String> baseLocaleKeys,  Set<(String key, String locale)> dirtyCells,  Set<String> dirtyLocales,  Set<(String, String)> errorCells,  bool hasUnsavedChanges,  bool showOnlyErrors,  bool showOnlyUntranslated,  String searchQuery,  bool isLoading,  bool isSaving,  (String key, String locale)? lastEditedCell,  DateTime? lastSavedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectState() when $default != null:
return $default(_that.folderPath,_that.baseLocale,_that.locales,_that.entries,_that.baseLocaleKeys,_that.dirtyCells,_that.dirtyLocales,_that.errorCells,_that.hasUnsavedChanges,_that.showOnlyErrors,_that.showOnlyUntranslated,_that.searchQuery,_that.isLoading,_that.isSaving,_that.lastEditedCell,_that.lastSavedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? folderPath,  String baseLocale,  List<String> locales,  List<TranslationEntry> entries,  Set<String> baseLocaleKeys,  Set<(String key, String locale)> dirtyCells,  Set<String> dirtyLocales,  Set<(String, String)> errorCells,  bool hasUnsavedChanges,  bool showOnlyErrors,  bool showOnlyUntranslated,  String searchQuery,  bool isLoading,  bool isSaving,  (String key, String locale)? lastEditedCell,  DateTime? lastSavedAt)  $default,) {final _that = this;
switch (_that) {
case _ProjectState():
return $default(_that.folderPath,_that.baseLocale,_that.locales,_that.entries,_that.baseLocaleKeys,_that.dirtyCells,_that.dirtyLocales,_that.errorCells,_that.hasUnsavedChanges,_that.showOnlyErrors,_that.showOnlyUntranslated,_that.searchQuery,_that.isLoading,_that.isSaving,_that.lastEditedCell,_that.lastSavedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? folderPath,  String baseLocale,  List<String> locales,  List<TranslationEntry> entries,  Set<String> baseLocaleKeys,  Set<(String key, String locale)> dirtyCells,  Set<String> dirtyLocales,  Set<(String, String)> errorCells,  bool hasUnsavedChanges,  bool showOnlyErrors,  bool showOnlyUntranslated,  String searchQuery,  bool isLoading,  bool isSaving,  (String key, String locale)? lastEditedCell,  DateTime? lastSavedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProjectState() when $default != null:
return $default(_that.folderPath,_that.baseLocale,_that.locales,_that.entries,_that.baseLocaleKeys,_that.dirtyCells,_that.dirtyLocales,_that.errorCells,_that.hasUnsavedChanges,_that.showOnlyErrors,_that.showOnlyUntranslated,_that.searchQuery,_that.isLoading,_that.isSaving,_that.lastEditedCell,_that.lastSavedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ProjectState implements ProjectState {
  const _ProjectState({this.folderPath, this.baseLocale = 'en', final  List<String> locales = const <String>[], final  List<TranslationEntry> entries = const <TranslationEntry>[], final  Set<String> baseLocaleKeys = const <String>{}, final  Set<(String key, String locale)> dirtyCells = const <(String, String)>{}, final  Set<String> dirtyLocales = const <String>{}, final  Set<(String, String)> errorCells = const <(String, String)>{}, this.hasUnsavedChanges = false, this.showOnlyErrors = false, this.showOnlyUntranslated = false, this.searchQuery = '', this.isLoading = false, this.isSaving = false, this.lastEditedCell, this.lastSavedAt}): _locales = locales,_entries = entries,_baseLocaleKeys = baseLocaleKeys,_dirtyCells = dirtyCells,_dirtyLocales = dirtyLocales,_errorCells = errorCells;
  

@override final  String? folderPath;
@override@JsonKey() final  String baseLocale;
 final  List<String> _locales;
@override@JsonKey() List<String> get locales {
  if (_locales is EqualUnmodifiableListView) return _locales;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_locales);
}

 final  List<TranslationEntry> _entries;
@override@JsonKey() List<TranslationEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

 final  Set<String> _baseLocaleKeys;
@override@JsonKey() Set<String> get baseLocaleKeys {
  if (_baseLocaleKeys is EqualUnmodifiableSetView) return _baseLocaleKeys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_baseLocaleKeys);
}

 final  Set<(String key, String locale)> _dirtyCells;
@override@JsonKey() Set<(String key, String locale)> get dirtyCells {
  if (_dirtyCells is EqualUnmodifiableSetView) return _dirtyCells;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_dirtyCells);
}

 final  Set<String> _dirtyLocales;
@override@JsonKey() Set<String> get dirtyLocales {
  if (_dirtyLocales is EqualUnmodifiableSetView) return _dirtyLocales;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_dirtyLocales);
}

 final  Set<(String, String)> _errorCells;
@override@JsonKey() Set<(String, String)> get errorCells {
  if (_errorCells is EqualUnmodifiableSetView) return _errorCells;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_errorCells);
}

@override@JsonKey() final  bool hasUnsavedChanges;
@override@JsonKey() final  bool showOnlyErrors;
@override@JsonKey() final  bool showOnlyUntranslated;
@override@JsonKey() final  String searchQuery;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isSaving;
@override final  (String key, String locale)? lastEditedCell;
@override final  DateTime? lastSavedAt;

/// Create a copy of ProjectState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectStateCopyWith<_ProjectState> get copyWith => __$ProjectStateCopyWithImpl<_ProjectState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectState&&(identical(other.folderPath, folderPath) || other.folderPath == folderPath)&&(identical(other.baseLocale, baseLocale) || other.baseLocale == baseLocale)&&const DeepCollectionEquality().equals(other._locales, _locales)&&const DeepCollectionEquality().equals(other._entries, _entries)&&const DeepCollectionEquality().equals(other._baseLocaleKeys, _baseLocaleKeys)&&const DeepCollectionEquality().equals(other._dirtyCells, _dirtyCells)&&const DeepCollectionEquality().equals(other._dirtyLocales, _dirtyLocales)&&const DeepCollectionEquality().equals(other._errorCells, _errorCells)&&(identical(other.hasUnsavedChanges, hasUnsavedChanges) || other.hasUnsavedChanges == hasUnsavedChanges)&&(identical(other.showOnlyErrors, showOnlyErrors) || other.showOnlyErrors == showOnlyErrors)&&(identical(other.showOnlyUntranslated, showOnlyUntranslated) || other.showOnlyUntranslated == showOnlyUntranslated)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.lastEditedCell, lastEditedCell) || other.lastEditedCell == lastEditedCell)&&(identical(other.lastSavedAt, lastSavedAt) || other.lastSavedAt == lastSavedAt));
}


@override
int get hashCode => Object.hash(runtimeType,folderPath,baseLocale,const DeepCollectionEquality().hash(_locales),const DeepCollectionEquality().hash(_entries),const DeepCollectionEquality().hash(_baseLocaleKeys),const DeepCollectionEquality().hash(_dirtyCells),const DeepCollectionEquality().hash(_dirtyLocales),const DeepCollectionEquality().hash(_errorCells),hasUnsavedChanges,showOnlyErrors,showOnlyUntranslated,searchQuery,isLoading,isSaving,lastEditedCell,lastSavedAt);

@override
String toString() {
  return 'ProjectState(folderPath: $folderPath, baseLocale: $baseLocale, locales: $locales, entries: $entries, baseLocaleKeys: $baseLocaleKeys, dirtyCells: $dirtyCells, dirtyLocales: $dirtyLocales, errorCells: $errorCells, hasUnsavedChanges: $hasUnsavedChanges, showOnlyErrors: $showOnlyErrors, showOnlyUntranslated: $showOnlyUntranslated, searchQuery: $searchQuery, isLoading: $isLoading, isSaving: $isSaving, lastEditedCell: $lastEditedCell, lastSavedAt: $lastSavedAt)';
}


}

/// @nodoc
abstract mixin class _$ProjectStateCopyWith<$Res> implements $ProjectStateCopyWith<$Res> {
  factory _$ProjectStateCopyWith(_ProjectState value, $Res Function(_ProjectState) _then) = __$ProjectStateCopyWithImpl;
@override @useResult
$Res call({
 String? folderPath, String baseLocale, List<String> locales, List<TranslationEntry> entries, Set<String> baseLocaleKeys, Set<(String key, String locale)> dirtyCells, Set<String> dirtyLocales, Set<(String, String)> errorCells, bool hasUnsavedChanges, bool showOnlyErrors, bool showOnlyUntranslated, String searchQuery, bool isLoading, bool isSaving, (String key, String locale)? lastEditedCell, DateTime? lastSavedAt
});




}
/// @nodoc
class __$ProjectStateCopyWithImpl<$Res>
    implements _$ProjectStateCopyWith<$Res> {
  __$ProjectStateCopyWithImpl(this._self, this._then);

  final _ProjectState _self;
  final $Res Function(_ProjectState) _then;

/// Create a copy of ProjectState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? folderPath = freezed,Object? baseLocale = null,Object? locales = null,Object? entries = null,Object? baseLocaleKeys = null,Object? dirtyCells = null,Object? dirtyLocales = null,Object? errorCells = null,Object? hasUnsavedChanges = null,Object? showOnlyErrors = null,Object? showOnlyUntranslated = null,Object? searchQuery = null,Object? isLoading = null,Object? isSaving = null,Object? lastEditedCell = freezed,Object? lastSavedAt = freezed,}) {
  return _then(_ProjectState(
folderPath: freezed == folderPath ? _self.folderPath : folderPath // ignore: cast_nullable_to_non_nullable
as String?,baseLocale: null == baseLocale ? _self.baseLocale : baseLocale // ignore: cast_nullable_to_non_nullable
as String,locales: null == locales ? _self._locales : locales // ignore: cast_nullable_to_non_nullable
as List<String>,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<TranslationEntry>,baseLocaleKeys: null == baseLocaleKeys ? _self._baseLocaleKeys : baseLocaleKeys // ignore: cast_nullable_to_non_nullable
as Set<String>,dirtyCells: null == dirtyCells ? _self._dirtyCells : dirtyCells // ignore: cast_nullable_to_non_nullable
as Set<(String key, String locale)>,dirtyLocales: null == dirtyLocales ? _self._dirtyLocales : dirtyLocales // ignore: cast_nullable_to_non_nullable
as Set<String>,errorCells: null == errorCells ? _self._errorCells : errorCells // ignore: cast_nullable_to_non_nullable
as Set<(String, String)>,hasUnsavedChanges: null == hasUnsavedChanges ? _self.hasUnsavedChanges : hasUnsavedChanges // ignore: cast_nullable_to_non_nullable
as bool,showOnlyErrors: null == showOnlyErrors ? _self.showOnlyErrors : showOnlyErrors // ignore: cast_nullable_to_non_nullable
as bool,showOnlyUntranslated: null == showOnlyUntranslated ? _self.showOnlyUntranslated : showOnlyUntranslated // ignore: cast_nullable_to_non_nullable
as bool,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,lastEditedCell: freezed == lastEditedCell ? _self.lastEditedCell : lastEditedCell // ignore: cast_nullable_to_non_nullable
as (String key, String locale)?,lastSavedAt: freezed == lastSavedAt ? _self.lastSavedAt : lastSavedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
