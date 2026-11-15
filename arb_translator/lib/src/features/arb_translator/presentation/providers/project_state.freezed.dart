// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProjectState {

 String? get folderPath; String get baseLocale; String get fileNamePrefix; List<String> get locales; List<TranslationEntry> get entries; Set<String> get baseLocaleKeys; Set<(String, String,)> get dirtyCells; Set<String> get dirtyLocales; Set<(String, String,)> get errorCells;/// Non-empty translations whose base-locale source changed after they were made.
 Set<(String, String,)> get staleCells; bool get hasUnsavedChanges; bool get showOnlyErrors; bool get showNeedsTranslation; String get searchQuery; bool get isLoading; bool get isSaving; (String, String,)? get lastEditedCell; DateTime? get lastSavedAt;
/// Create a copy of ProjectState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectStateCopyWith<ProjectState> get copyWith => _$ProjectStateCopyWithImpl<ProjectState>(this as ProjectState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProjectState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectState&&(identical(other.folderPath, _this.folderPath) || other.folderPath == _this.folderPath)&&(identical(other.baseLocale, _this.baseLocale) || other.baseLocale == _this.baseLocale)&&(identical(other.fileNamePrefix, _this.fileNamePrefix) || other.fileNamePrefix == _this.fileNamePrefix)&&const DeepCollectionEquality().equals(other.locales, _this.locales)&&const DeepCollectionEquality().equals(other.entries, _this.entries)&&const DeepCollectionEquality().equals(other.baseLocaleKeys, _this.baseLocaleKeys)&&const DeepCollectionEquality().equals(other.dirtyCells, _this.dirtyCells)&&const DeepCollectionEquality().equals(other.dirtyLocales, _this.dirtyLocales)&&const DeepCollectionEquality().equals(other.errorCells, _this.errorCells)&&const DeepCollectionEquality().equals(other.staleCells, _this.staleCells)&&(identical(other.hasUnsavedChanges, _this.hasUnsavedChanges) || other.hasUnsavedChanges == _this.hasUnsavedChanges)&&(identical(other.showOnlyErrors, _this.showOnlyErrors) || other.showOnlyErrors == _this.showOnlyErrors)&&(identical(other.showNeedsTranslation, _this.showNeedsTranslation) || other.showNeedsTranslation == _this.showNeedsTranslation)&&(identical(other.searchQuery, _this.searchQuery) || other.searchQuery == _this.searchQuery)&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&(identical(other.isSaving, _this.isSaving) || other.isSaving == _this.isSaving)&&(identical(other.lastEditedCell, _this.lastEditedCell) || other.lastEditedCell == _this.lastEditedCell)&&(identical(other.lastSavedAt, _this.lastSavedAt) || other.lastSavedAt == _this.lastSavedAt));
}


@override
int get hashCode {
  final _this = this as ProjectState;
  return Object.hash(runtimeType,_this.folderPath,_this.baseLocale,_this.fileNamePrefix,const DeepCollectionEquality().hash(_this.locales),const DeepCollectionEquality().hash(_this.entries),const DeepCollectionEquality().hash(_this.baseLocaleKeys),const DeepCollectionEquality().hash(_this.dirtyCells),const DeepCollectionEquality().hash(_this.dirtyLocales),const DeepCollectionEquality().hash(_this.errorCells),const DeepCollectionEquality().hash(_this.staleCells),_this.hasUnsavedChanges,_this.showOnlyErrors,_this.showNeedsTranslation,_this.searchQuery,_this.isLoading,_this.isSaving,_this.lastEditedCell,_this.lastSavedAt);
}

@override
String toString() {
  final _this = this as ProjectState;
  return 'ProjectState(folderPath: ${_this.folderPath}, baseLocale: ${_this.baseLocale}, fileNamePrefix: ${_this.fileNamePrefix}, locales: ${_this.locales}, entries: ${_this.entries}, baseLocaleKeys: ${_this.baseLocaleKeys}, dirtyCells: ${_this.dirtyCells}, dirtyLocales: ${_this.dirtyLocales}, errorCells: ${_this.errorCells}, staleCells: ${_this.staleCells}, hasUnsavedChanges: ${_this.hasUnsavedChanges}, showOnlyErrors: ${_this.showOnlyErrors}, showNeedsTranslation: ${_this.showNeedsTranslation}, searchQuery: ${_this.searchQuery}, isLoading: ${_this.isLoading}, isSaving: ${_this.isSaving}, lastEditedCell: ${_this.lastEditedCell}, lastSavedAt: ${_this.lastSavedAt})';
}


}

/// @nodoc
abstract mixin class $ProjectStateCopyWith<$Res>  {
  factory $ProjectStateCopyWith(ProjectState value, $Res Function(ProjectState) _then) = _$ProjectStateCopyWithImpl;
@useResult
$Res call({
 String? folderPath, String baseLocale, String fileNamePrefix, List<String> locales, List<TranslationEntry> entries, Set<String> baseLocaleKeys, Set<(String, String,)> dirtyCells, Set<String> dirtyLocales, Set<(String, String,)> errorCells, Set<(String, String,)> staleCells, bool hasUnsavedChanges, bool showOnlyErrors, bool showNeedsTranslation, String searchQuery, bool isLoading, bool isSaving, (String, String,)? lastEditedCell, DateTime? lastSavedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? folderPath = freezed,Object? baseLocale = null,Object? fileNamePrefix = null,Object? locales = null,Object? entries = null,Object? baseLocaleKeys = null,Object? dirtyCells = null,Object? dirtyLocales = null,Object? errorCells = null,Object? staleCells = null,Object? hasUnsavedChanges = null,Object? showOnlyErrors = null,Object? showNeedsTranslation = null,Object? searchQuery = null,Object? isLoading = null,Object? isSaving = null,Object? lastEditedCell = freezed,Object? lastSavedAt = freezed,}) {
  return _then(ProjectState(
folderPath: freezed == folderPath ? _self.folderPath : folderPath // ignore: cast_nullable_to_non_nullable
as String?,baseLocale: null == baseLocale ? _self.baseLocale : baseLocale // ignore: cast_nullable_to_non_nullable
as String,fileNamePrefix: null == fileNamePrefix ? _self.fileNamePrefix : fileNamePrefix // ignore: cast_nullable_to_non_nullable
as String,locales: null == locales ? _self.locales : locales // ignore: cast_nullable_to_non_nullable
as List<String>,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<TranslationEntry>,baseLocaleKeys: null == baseLocaleKeys ? _self.baseLocaleKeys : baseLocaleKeys // ignore: cast_nullable_to_non_nullable
as Set<String>,dirtyCells: null == dirtyCells ? _self.dirtyCells : dirtyCells // ignore: cast_nullable_to_non_nullable
as Set<(String, String,)>,dirtyLocales: null == dirtyLocales ? _self.dirtyLocales : dirtyLocales // ignore: cast_nullable_to_non_nullable
as Set<String>,errorCells: null == errorCells ? _self.errorCells : errorCells // ignore: cast_nullable_to_non_nullable
as Set<(String, String,)>,staleCells: null == staleCells ? _self.staleCells : staleCells // ignore: cast_nullable_to_non_nullable
as Set<(String, String,)>,hasUnsavedChanges: null == hasUnsavedChanges ? _self.hasUnsavedChanges : hasUnsavedChanges // ignore: cast_nullable_to_non_nullable
as bool,showOnlyErrors: null == showOnlyErrors ? _self.showOnlyErrors : showOnlyErrors // ignore: cast_nullable_to_non_nullable
as bool,showNeedsTranslation: null == showNeedsTranslation ? _self.showNeedsTranslation : showNeedsTranslation // ignore: cast_nullable_to_non_nullable
as bool,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,lastEditedCell: freezed == lastEditedCell ? _self.lastEditedCell : lastEditedCell // ignore: cast_nullable_to_non_nullable
as (String, String,)?,lastSavedAt: freezed == lastSavedAt ? _self.lastSavedAt : lastSavedAt // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? folderPath,  String baseLocale,  String fileNamePrefix,  List<String> locales,  List<TranslationEntry> entries,  Set<String> baseLocaleKeys,  Set<(String, String,)> dirtyCells,  Set<String> dirtyLocales,  Set<(String, String,)> errorCells,  Set<(String, String,)> staleCells,  bool hasUnsavedChanges,  bool showOnlyErrors,  bool showNeedsTranslation,  String searchQuery,  bool isLoading,  bool isSaving,  (String, String,)? lastEditedCell,  DateTime? lastSavedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectState() when $default != null:
return $default(_that.folderPath,_that.baseLocale,_that.fileNamePrefix,_that.locales,_that.entries,_that.baseLocaleKeys,_that.dirtyCells,_that.dirtyLocales,_that.errorCells,_that.staleCells,_that.hasUnsavedChanges,_that.showOnlyErrors,_that.showNeedsTranslation,_that.searchQuery,_that.isLoading,_that.isSaving,_that.lastEditedCell,_that.lastSavedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? folderPath,  String baseLocale,  String fileNamePrefix,  List<String> locales,  List<TranslationEntry> entries,  Set<String> baseLocaleKeys,  Set<(String, String,)> dirtyCells,  Set<String> dirtyLocales,  Set<(String, String,)> errorCells,  Set<(String, String,)> staleCells,  bool hasUnsavedChanges,  bool showOnlyErrors,  bool showNeedsTranslation,  String searchQuery,  bool isLoading,  bool isSaving,  (String, String,)? lastEditedCell,  DateTime? lastSavedAt)  $default,) {final _that = this;
switch (_that) {
case _ProjectState():
return $default(_that.folderPath,_that.baseLocale,_that.fileNamePrefix,_that.locales,_that.entries,_that.baseLocaleKeys,_that.dirtyCells,_that.dirtyLocales,_that.errorCells,_that.staleCells,_that.hasUnsavedChanges,_that.showOnlyErrors,_that.showNeedsTranslation,_that.searchQuery,_that.isLoading,_that.isSaving,_that.lastEditedCell,_that.lastSavedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? folderPath,  String baseLocale,  String fileNamePrefix,  List<String> locales,  List<TranslationEntry> entries,  Set<String> baseLocaleKeys,  Set<(String, String,)> dirtyCells,  Set<String> dirtyLocales,  Set<(String, String,)> errorCells,  Set<(String, String,)> staleCells,  bool hasUnsavedChanges,  bool showOnlyErrors,  bool showNeedsTranslation,  String searchQuery,  bool isLoading,  bool isSaving,  (String, String,)? lastEditedCell,  DateTime? lastSavedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProjectState() when $default != null:
return $default(_that.folderPath,_that.baseLocale,_that.fileNamePrefix,_that.locales,_that.entries,_that.baseLocaleKeys,_that.dirtyCells,_that.dirtyLocales,_that.errorCells,_that.staleCells,_that.hasUnsavedChanges,_that.showOnlyErrors,_that.showNeedsTranslation,_that.searchQuery,_that.isLoading,_that.isSaving,_that.lastEditedCell,_that.lastSavedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ProjectState implements ProjectState {
  const _ProjectState({this.folderPath, this.baseLocale = 'en', this.fileNamePrefix = 'app_',  List<String> locales = const <String>[],  List<TranslationEntry> entries = const <TranslationEntry>[],  Set<String> baseLocaleKeys = const <String>{},  Set<(String, String,)> dirtyCells = const <(String, String)>{},  Set<String> dirtyLocales = const <String>{},  Set<(String, String,)> errorCells = const <(String, String)>{},  Set<(String, String,)> staleCells = const <(String, String)>{}, this.hasUnsavedChanges = false, this.showOnlyErrors = false, this.showNeedsTranslation = false, this.searchQuery = '', this.isLoading = false, this.isSaving = false, this.lastEditedCell, this.lastSavedAt}): _locales = locales,_entries = entries,_baseLocaleKeys = baseLocaleKeys,_dirtyCells = dirtyCells,_dirtyLocales = dirtyLocales,_errorCells = errorCells,_staleCells = staleCells;
  

@override final  String? folderPath;
@override@JsonKey() final  String baseLocale;
@override@JsonKey() final  String fileNamePrefix;
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

 final  Set<(String, String,)> _dirtyCells;
@override@JsonKey() Set<(String, String,)> get dirtyCells {
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

 final  Set<(String, String,)> _errorCells;
@override@JsonKey() Set<(String, String,)> get errorCells {
  if (_errorCells is EqualUnmodifiableSetView) return _errorCells;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_errorCells);
}

/// Non-empty translations whose base-locale source changed after they were made.
 final  Set<(String, String,)> _staleCells;
/// Non-empty translations whose base-locale source changed after they were made.
@override@JsonKey() Set<(String, String,)> get staleCells {
  if (_staleCells is EqualUnmodifiableSetView) return _staleCells;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_staleCells);
}

@override@JsonKey() final  bool hasUnsavedChanges;
@override@JsonKey() final  bool showOnlyErrors;
@override@JsonKey() final  bool showNeedsTranslation;
@override@JsonKey() final  String searchQuery;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isSaving;
@override final  (String, String,)? lastEditedCell;
@override final  DateTime? lastSavedAt;

/// Create a copy of ProjectState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectStateCopyWith<_ProjectState> get copyWith => __$ProjectStateCopyWithImpl<_ProjectState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectState&&(identical(other.folderPath, folderPath) || other.folderPath == folderPath)&&(identical(other.baseLocale, baseLocale) || other.baseLocale == baseLocale)&&(identical(other.fileNamePrefix, fileNamePrefix) || other.fileNamePrefix == fileNamePrefix)&&const DeepCollectionEquality().equals(other.locales, _locales)&&const DeepCollectionEquality().equals(other.entries, _entries)&&const DeepCollectionEquality().equals(other.baseLocaleKeys, _baseLocaleKeys)&&const DeepCollectionEquality().equals(other.dirtyCells, _dirtyCells)&&const DeepCollectionEquality().equals(other.dirtyLocales, _dirtyLocales)&&const DeepCollectionEquality().equals(other.errorCells, _errorCells)&&const DeepCollectionEquality().equals(other.staleCells, _staleCells)&&(identical(other.hasUnsavedChanges, hasUnsavedChanges) || other.hasUnsavedChanges == hasUnsavedChanges)&&(identical(other.showOnlyErrors, showOnlyErrors) || other.showOnlyErrors == showOnlyErrors)&&(identical(other.showNeedsTranslation, showNeedsTranslation) || other.showNeedsTranslation == showNeedsTranslation)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.lastEditedCell, lastEditedCell) || other.lastEditedCell == lastEditedCell)&&(identical(other.lastSavedAt, lastSavedAt) || other.lastSavedAt == lastSavedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,folderPath,baseLocale,fileNamePrefix,const DeepCollectionEquality().hash(_locales),const DeepCollectionEquality().hash(_entries),const DeepCollectionEquality().hash(_baseLocaleKeys),const DeepCollectionEquality().hash(_dirtyCells),const DeepCollectionEquality().hash(_dirtyLocales),const DeepCollectionEquality().hash(_errorCells),const DeepCollectionEquality().hash(_staleCells),hasUnsavedChanges,showOnlyErrors,showNeedsTranslation,searchQuery,isLoading,isSaving,lastEditedCell,lastSavedAt);
}

@override
String toString() {
    return 'ProjectState(folderPath: $folderPath, baseLocale: $baseLocale, fileNamePrefix: $fileNamePrefix, locales: $locales, entries: $entries, baseLocaleKeys: $baseLocaleKeys, dirtyCells: $dirtyCells, dirtyLocales: $dirtyLocales, errorCells: $errorCells, staleCells: $staleCells, hasUnsavedChanges: $hasUnsavedChanges, showOnlyErrors: $showOnlyErrors, showNeedsTranslation: $showNeedsTranslation, searchQuery: $searchQuery, isLoading: $isLoading, isSaving: $isSaving, lastEditedCell: $lastEditedCell, lastSavedAt: $lastSavedAt)';
}


}

/// @nodoc
abstract mixin class _$ProjectStateCopyWith<$Res> implements $ProjectStateCopyWith<$Res> {
  factory _$ProjectStateCopyWith(_ProjectState value, $Res Function(_ProjectState) _then) = __$ProjectStateCopyWithImpl;
@override @useResult
$Res call({
 String? folderPath, String baseLocale, String fileNamePrefix, List<String> locales, List<TranslationEntry> entries, Set<String> baseLocaleKeys, Set<(String, String,)> dirtyCells, Set<String> dirtyLocales, Set<(String, String,)> errorCells, Set<(String, String,)> staleCells, bool hasUnsavedChanges, bool showOnlyErrors, bool showNeedsTranslation, String searchQuery, bool isLoading, bool isSaving, (String, String,)? lastEditedCell, DateTime? lastSavedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? folderPath = freezed,Object? baseLocale = null,Object? fileNamePrefix = null,Object? locales = null,Object? entries = null,Object? baseLocaleKeys = null,Object? dirtyCells = null,Object? dirtyLocales = null,Object? errorCells = null,Object? staleCells = null,Object? hasUnsavedChanges = null,Object? showOnlyErrors = null,Object? showNeedsTranslation = null,Object? searchQuery = null,Object? isLoading = null,Object? isSaving = null,Object? lastEditedCell = freezed,Object? lastSavedAt = freezed,}) {
  return _then(_ProjectState(
folderPath: freezed == folderPath ? _self.folderPath : folderPath // ignore: cast_nullable_to_non_nullable
as String?,baseLocale: null == baseLocale ? _self.baseLocale : baseLocale // ignore: cast_nullable_to_non_nullable
as String,fileNamePrefix: null == fileNamePrefix ? _self.fileNamePrefix : fileNamePrefix // ignore: cast_nullable_to_non_nullable
as String,locales: null == locales ? _self._locales : locales // ignore: cast_nullable_to_non_nullable
as List<String>,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<TranslationEntry>,baseLocaleKeys: null == baseLocaleKeys ? _self._baseLocaleKeys : baseLocaleKeys // ignore: cast_nullable_to_non_nullable
as Set<String>,dirtyCells: null == dirtyCells ? _self._dirtyCells : dirtyCells // ignore: cast_nullable_to_non_nullable
as Set<(String, String,)>,dirtyLocales: null == dirtyLocales ? _self._dirtyLocales : dirtyLocales // ignore: cast_nullable_to_non_nullable
as Set<String>,errorCells: null == errorCells ? _self._errorCells : errorCells // ignore: cast_nullable_to_non_nullable
as Set<(String, String,)>,staleCells: null == staleCells ? _self._staleCells : staleCells // ignore: cast_nullable_to_non_nullable
as Set<(String, String,)>,hasUnsavedChanges: null == hasUnsavedChanges ? _self.hasUnsavedChanges : hasUnsavedChanges // ignore: cast_nullable_to_non_nullable
as bool,showOnlyErrors: null == showOnlyErrors ? _self.showOnlyErrors : showOnlyErrors // ignore: cast_nullable_to_non_nullable
as bool,showNeedsTranslation: null == showNeedsTranslation ? _self.showNeedsTranslation : showNeedsTranslation // ignore: cast_nullable_to_non_nullable
as bool,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,lastEditedCell: freezed == lastEditedCell ? _self.lastEditedCell : lastEditedCell // ignore: cast_nullable_to_non_nullable
as (String, String,)?,lastSavedAt: freezed == lastSavedAt ? _self.lastSavedAt : lastSavedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
