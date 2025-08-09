import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_cell_translation_provider.g.dart';

/// Active per-cell translation indicator using a generated Notifier provider.
/// Stores (key, locale) of the cell currently being translated.
@riverpod
class ActiveCellTranslation extends _$ActiveCellTranslation {
  @override
  (String, String)? build() => null;

  void start(String key, String locale) => state = (key, locale);
  void clear(String key, String locale) {
    if (state == (key, locale)) state = null;
  }

  void clearAny() => state = null;
}
