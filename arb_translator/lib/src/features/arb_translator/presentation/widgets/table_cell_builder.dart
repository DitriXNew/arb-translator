import 'package:arb_translator/src/core/theme/color_tokens.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/editing_cell_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_controller.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_state.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/widgets/translation_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Builder for individual table cells with proper decoration and behavior
class TableCellBuilder {
  const TableCellBuilder({
    required this.ref,
    required this.state,
    required this.colWidths,
    required this.selectedKeys,
    required this.onShowCellMenu,
    required this.onToggleSelection,
    required this.horizontalScrollController,
    this.activeTranslatingCell,
    this.editingCell,
  });

  final WidgetRef ref;
  final ProjectState state;
  final Map<String, double> colWidths;
  final Set<String> selectedKeys;
  final void Function({required Offset position, required TranslationEntry entry, required String colId})
  onShowCellMenu;
  final void Function(String key, {required bool add}) onToggleSelection;
  final ScrollController horizontalScrollController;
  /// Активная ячейка, которая сейчас переводится (key, locale)
  final (String, String)? activeTranslatingCell;
  /// Активная редактируемая ячейка (key, colId)
  final (String, String)? editingCell;

  Widget buildCell(TranslationEntry e, String colId) {
    final controller = ref.read(projectControllerProvider.notifier);
    final dirty = state.dirtyCells.contains((e.key, colId.startsWith('loc_') ? colId.substring(4) : state.baseLocale));
    final isError = colId.startsWith('loc_') && state.errorCells.contains((e.key, colId.substring(4)));
    final isSourceChanged = state.sourceChangedKeys.contains(e.key);
    // Используем переданное значение вместо ref.watch()
    final isTranslating = colId.startsWith('loc_') && activeTranslatingCell == (e.key, colId.substring(4));
    // Проверяем, редактируется ли эта ячейка
    final isEditing = editingCell == (e.key, colId);

    Color bg = Colors.transparent;
    if (isError) {
      bg = AppColors.danger.withValues(alpha: 0.15);
    } else if (dirty) {
      bg = AppColors.rowHover.withValues(alpha: 0.35);
    }

    if (isTranslating) {
      // Light accent overlay to signal in-progress translation
      bg = AppColors.accent.withValues(alpha: 0.25);
    }

    // Selection overlay
    if (selectedKeys.contains(e.key)) {
      bg = bg == Colors.transparent ? AppColors.accent.withValues(alpha: 0.10) : bg.withValues(alpha: 0.55);
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0xFF404040)),
          bottom: BorderSide(color: Color(0xFF404040)),
        ),
      ),
      child: Stack(
        children: [
          _buildCellContent(e, colId, bg, controller, isSourceChanged, isEditing),
          if (isTranslating) const Positioned(top: 2, left: 4, width: 12, height: 12, child: _MiniSpinner()),
        ],
      ),
    );
  }

  Widget _buildCellContent(
    TranslationEntry e,
    String colId,
    Color bg,
    ProjectController controller,
    bool isSourceChanged,
    bool isEditing,
  ) {
    // Колбеки для редактирования
    void startEditing() {
      ref.read(editingCellProvider.notifier).startEditing(e.key, colId);
    }
    void stopEditing() {
      ref.read(editingCellProvider.notifier).stopEditing();
    }

    switch (colId) {
      case 'key':
        return Stack(
          children: [
            TranslationCell(
              width: colWidths[colId]! - 1,
              text: e.key,
              editable: true,
              isEditing: isEditing,
              centerVertically: true,
              background: bg,
              onCommit: (v) {
                final trimmed = v.trim();
                if (trimmed.isNotEmpty && trimmed != e.key) {
                  controller.renameKey(oldKey: e.key, newKey: trimmed);
                }
              },
              onSecondaryTapDown: (d) => onShowCellMenu(position: d.globalPosition, entry: e, colId: colId),
              onTap: () => onToggleSelection(e.key, add: false),
              onStartEditing: startEditing,
              onStopEditing: stopEditing,
              horizontalScrollController: horizontalScrollController,
            ),
            if (isSourceChanged)
              const Positioned(
                top: 2,
                right: 4,
                child: Tooltip(
                  message: 'Source text has changed - consider retranslating',
                  child: Icon(Icons.refresh, size: 16, color: Colors.orange),
                ),
              ),
          ],
        );

      case 'description':
        return TranslationCell(
          width: colWidths[colId]! - 1,
          text: e.meta.description ?? '',
          multiline: true,
          centerVertically: true,
          background: bg,
          onSecondaryTapDown: (d) => onShowCellMenu(position: d.globalPosition, entry: e, colId: colId),
          onTap: () => onToggleSelection(e.key, add: false),
          horizontalScrollController: horizontalScrollController,
        );

      case 'placeholders':
        return TranslationCell(
          width: colWidths[colId]! - 1,
          text: e.meta.placeholders.join(', '),
          centerVertically: true,
          background: bg,
          onSecondaryTapDown: (d) => onShowCellMenu(position: d.globalPosition, entry: e, colId: colId),
          onTap: () => onToggleSelection(e.key, add: false),
          horizontalScrollController: horizontalScrollController,
        );

      default:
        if (colId.startsWith('loc_')) {
          final locale = colId.substring(4);
          final value = e.values[locale] ?? '';
          final isBase = locale == state.baseLocale;

          return TranslationCell(
            width: colWidths[colId]! - 1,
            text: value,
            editable: true,
            isEditing: isEditing,
            multiline: true,
            background: bg,
            onCommit: (v) => controller.updateCell(key: e.key, locale: locale, text: v),
            onSecondaryTapDown: (d) => onShowCellMenu(position: d.globalPosition, entry: e, colId: colId),
            onTap: () => onToggleSelection(e.key, add: !isBase),
            onStartEditing: startEditing,
            onStopEditing: stopEditing,
            horizontalScrollController: horizontalScrollController,
          );
        }
        return const SizedBox();
    }
  }
}

/// Tiny spinner used inside a cell to indicate per-cell translation progress.
class _MiniSpinner extends StatefulWidget {
  const _MiniSpinner();
  @override
  State<_MiniSpinner> createState() => _MiniSpinnerState();
}

class _MiniSpinnerState extends State<_MiniSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
    ..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (context, _) =>
        Transform.rotate(angle: _c.value * 6.28318, child: const CircularProgressIndicator(strokeWidth: 2)),
  );
}
