import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_state.freezed.dart';

@freezed
abstract class ProjectState with _$ProjectState {
  const factory ProjectState({
    String? folderPath,
    @Default('en') String baseLocale,
    @Default(<String>[]) List<String> locales,
    @Default(<TranslationEntry>[]) List<TranslationEntry> entries,
    @Default(<String>{}) Set<String> baseLocaleKeys,
    @Default(<(String, String)>{}) Set<(String key, String locale)> dirtyCells,
    @Default(<String>{}) Set<String> dirtyLocales,
    @Default(<(String, String)>{}) Set<(String, String)> errorCells,
    @Default(false) bool hasUnsavedChanges,
    @Default(false) bool showOnlyErrors,
    @Default(false) bool showOnlyUntranslated,
    @Default('') String searchQuery,
    @Default(false) bool isLoading,
    @Default(false) bool isSaving,
    (String key, String locale)? lastEditedCell,
    DateTime? lastSavedAt,
  }) = _ProjectState;
}
