import 'package:arb_translator/src/features/arb_translator/application/undo/commands.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UndoManager extends ChangeNotifier {
  final _undo = <ProjectUndoCommand>[];
  final _redo = <ProjectUndoCommand>[];

  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;

  void push(ProjectUndoCommand cmd) {
    _undo.add(cmd);
    _redo.clear();
    notifyListeners();
  }

  void undo() {
    if (!canUndo) return;
    final cmd = _undo.removeLast();
    cmd.revert();
    _redo.add(cmd);
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;
    final cmd = _redo.removeLast();
    cmd.apply();
    _undo.add(cmd);
    notifyListeners();
  }

  void clear() {
    _undo.clear();
    _redo.clear();
    notifyListeners();
  }
}

final undoManagerProvider = Provider<UndoManager>((ref) {
  final mgr = UndoManager();
  ref.onDispose(mgr.clear);
  return mgr;
});
