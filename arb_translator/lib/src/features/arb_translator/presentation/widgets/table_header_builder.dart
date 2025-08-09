import 'dart:math';

import 'package:arb_translator/src/core/theme/color_tokens.dart';
import 'package:arb_translator/src/core/theme/text_styles.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_controller.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Builder for table header cells with sorting and translation actions
class TableHeaderBuilder {
  const TableHeaderBuilder({
    required this.ref,
    required this.state,
    required this.colWidths,
    required this.sortColumn,
    required this.sortAsc,
    required this.onCycleSort,
    required this.onResizeColumn,
  });

  final WidgetRef ref;
  final ProjectState state;
  final Map<String, double> colWidths;
  final String? sortColumn;
  final bool sortAsc;
  final void Function(String colId) onCycleSort;
  final void Function(String colId, double delta) onResizeColumn;

  Widget buildHeaderCell(String colId) {
    final title = _getColumnTitle(colId);
    final sorted = sortColumn == colId;
    final asc = sortAsc;
    final dirtyLocale = colId.startsWith('loc_') && state.dirtyLocales.contains(colId.substring(4));
    final isBase = colId == 'loc_${state.baseLocale}';
    final canTranslateBulk = colId.startsWith('loc_') && !isBase;
    final color = sorted ? AppColors.accent : AppColors.textPrimary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onCycleSort(colId),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(
          color: Color(0xFF202020),
          border: Border(
            right: BorderSide(color: Color(0xFF404040)),
            bottom: BorderSide(color: Color(0xFF404040)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      title + (dirtyLocale ? '*' : ''),
                      style: AppTextStyles.tableHeader13.copyWith(color: color),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (sorted)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(asc ? Icons.arrow_drop_up : Icons.arrow_drop_down, size: 20, color: color),
                    ),
                ],
              ),
            ),
            if (canTranslateBulk) ..._buildTranslationActions(colId),
            _buildResizeHandle(colId),
          ],
        ),
      ),
    );
  }

  Widget buildHeaderRow(List<String> colIds) => Row(
    children: [
      for (final c in colIds)
        SizedBox(
          width: colWidths[c]! - 1, // Account for border width
          child: buildHeaderCell(c),
        ),
    ],
  );

  String _getColumnTitle(String colId) {
    switch (colId) {
      case 'key':
        return 'Key';
      case 'description':
        return 'Description';
      case 'placeholders':
        return 'Placeholders';
      default:
        if (colId.startsWith('loc_')) {
          return colId.substring(4);
        }
        return colId;
    }
  }

  List<Widget> _buildTranslationActions(String colId) => [
    SizedBox(
      width: 32,
      height: 32,
      child: Tooltip(
        message: 'Translate all',
        child: IconButton(
          iconSize: 16,
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.translate),
          onPressed: () =>
              ref.read(projectControllerProvider.notifier).translateBulk(locale: colId.substring(4), onlyEmpty: false),
        ),
      ),
    ),
    SizedBox(
      width: 32,
      height: 32,
      child: Tooltip(
        message: 'Translate empty only',
        child: IconButton(
          iconSize: 16,
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.lightbulb),
          onPressed: () =>
              ref.read(projectControllerProvider.notifier).translateBulk(locale: colId.substring(4), onlyEmpty: true),
        ),
      ),
    ),
  ];

  Widget _buildResizeHandle(String colId) => MouseRegion(
    cursor: SystemMouseCursors.resizeLeftRight,
    child: GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (d) {
        final newWidth = max(80, colWidths[colId]! + d.delta.dx);
        onResizeColumn(colId, newWidth - colWidths[colId]!);
      },
      child: const SizedBox(width: 6, height: double.infinity),
    ),
  );
}
