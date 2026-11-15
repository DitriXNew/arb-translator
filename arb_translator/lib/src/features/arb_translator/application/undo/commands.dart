abstract class ProjectUndoCommand {
  void apply();
  void revert();
}

class UpdateCellCommand implements ProjectUndoCommand {
  UpdateCellCommand({required this._apply, required this._revert});
  final void Function() _apply;
  final void Function() _revert;
  @override
  void apply() => _apply();
  @override
  void revert() => _revert();
}

class RenameKeyCommand implements ProjectUndoCommand {
  RenameKeyCommand({required this._apply, required this._revert});
  final void Function() _apply;
  final void Function() _revert;
  @override
  void apply() => _apply();
  @override
  void revert() => _revert();
}

class DeleteKeyCommand implements ProjectUndoCommand {
  DeleteKeyCommand({required this._apply, required this._revert});
  final void Function() _apply;
  final void Function() _revert;
  @override
  void apply() => _apply();
  @override
  void revert() => _revert();
}
