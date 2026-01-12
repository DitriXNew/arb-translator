import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Состояние активной редактируемой ячейки
/// (key, colId) - ключ записи и идентификатор колонки
class EditingCellNotifier extends Notifier<(String, String)?> {
  @override
  (String, String)? build() => null;

  /// Начать редактирование ячейки
  void startEditing(String key, String colId) {
    state = (key, colId);
  }

  /// Закончить редактирование
  void stopEditing() {
    state = null;
  }

  /// Проверить, редактируется ли данная ячейка
  bool isEditing(String key, String colId) {
    return state == (key, colId);
  }
}

final editingCellProvider = NotifierProvider<EditingCellNotifier, (String, String)?>(
  EditingCellNotifier.new,
);
