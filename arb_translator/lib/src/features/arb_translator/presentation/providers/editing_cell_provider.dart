import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State of the currently editing cell
/// (key, colId) - entry key and column identifier
class EditingCellNotifier extends Notifier<(String, String)?> {
  @override
  (String, String)? build() => null;

  /// Start editing a cell
  void startEditing(String key, String colId) {
    state = (key, colId);
  }

  /// Stop editing
  void stopEditing() {
    state = null;
  }

  /// Check if this cell is being edited
  bool isEditing(String key, String colId) => state == (key, colId);
}

final editingCellProvider = NotifierProvider<EditingCellNotifier, (String, String)?>(EditingCellNotifier.new);
