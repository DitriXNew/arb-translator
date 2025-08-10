abstract class ProjectUndoCommand {
  void apply();
  void revert();
}

class UpdateCellCommand implements ProjectUndoCommand {
  UpdateCellCommand({required void Function() apply, required void Function() revert})
    : _apply = apply,
      _revert = revert;
  final void Function() _apply;
  final void Function() _revert;
  @override
  void apply() => _apply();
  @override
  void revert() => _revert();
}

class RenameKeyCommand implements ProjectUndoCommand {
  RenameKeyCommand({required void Function() apply, required void Function() revert})
    : _apply = apply,
      _revert = revert;
  final void Function() _apply;
  final void Function() _revert;
  @override
  void apply() => _apply();
  @override
  void revert() => _revert();
}

class DeleteKeyCommand implements ProjectUndoCommand {
  DeleteKeyCommand({required void Function() apply, required void Function() revert})
    : _apply = apply,
      _revert = revert;
  final void Function() _apply;
  final void Function() _revert;
  @override
  void apply() => _apply();
  @override
  void revert() => _revert();
}
