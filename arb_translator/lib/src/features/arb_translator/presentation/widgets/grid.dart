import 'dart:math';

import 'package:arb_translator/src/core/theme/color_tokens.dart';
import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/active_cell_translation_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/editing_cell_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/filtered_entries_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_controller.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_state.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/widgets/table_cell_builder.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/widgets/table_header_builder.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/widgets/table_menu_handler.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/widgets/table_sort_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Custom lightweight translation table replacing PlutoGrid.
/// Features implemented:
///  - First 4 columns frozen (Key, Description, Placeholders, base locale)
///  - Column resize (drag divider in header)
///  - Sorting (tap header cycles none → asc → desc). Arrow icon shown.
///  - Inline edit for key (renames) & locale cells (commit on submit / focus loss)
///  - Delete row (trash icon in key cell)
///  - Per-cell translate button (non-base locales)
///  - Per-locale bulk translate button (header)
///  - Dirty & error cell highlighting
///  - ListView.builder virtualization for large (>5k) datasets
class TranslationGrid extends ConsumerStatefulWidget {
  const TranslationGrid({super.key});
  @override
  ConsumerState<TranslationGrid> createState() => TranslationGridState();
}

// Local intent used when grid is rendered standalone in tests (without ProjectPage shortcuts)
class _GridSaveIntent extends Intent {
  const _GridSaveIntent();
}

class TranslationGridState extends ConsumerState<TranslationGrid> {
  // Core state
  late List<String> _columnOrder;
  // Default column widths. Tuned so that frozen columns sum <= typical 800px test width
  // to avoid unavoidable overflow (frozen region is not horizontally scrollable).
  // key(200) + description(240) + placeholders(150) + base locale(200) = 790px
  final Map<String, double> _colWidths = {'key': 200, 'description': 240, 'placeholders': 150};
  String? _sortColumn;
  bool _sortAsc = true;
  final Set<String> _selectedKeys = {};

  // Scroll controllers
  final ScrollController _verticalScroll = ScrollController();
  final ScrollController _horizontalBody = ScrollController();

  // Component instances
  late TableSortHandler _sortHandler;
  late TableCellBuilder _cellBuilder;
  late TableMenuHandler _menuHandler;
  late TableHeaderBuilder _headerBuilder;

  @override
  void initState() {
    super.initState();
    _sortHandler = const TableSortHandler();
  }

  @override
  void dispose() {
    _verticalScroll.dispose();
    _horizontalBody.dispose();
    super.dispose();
  }

  void _ensureLocaleWidths(ProjectState state) {
    for (final l in state.locales) {
      final id = 'loc_$l';
      // Slightly narrower default to keep frozen width compact when base locale is frozen.
      _colWidths.putIfAbsent(id, () => 200);
    }
  }

  void _cycleSort(String col) {
    setState(() {
      final newColumn = _sortHandler.cycleSortState(
        colId: col,
        currentSortColumn: _sortColumn,
        currentSortAsc: _sortAsc,
      );
      if (newColumn != null) {
        _sortColumn = newColumn;
        _sortAsc = _sortHandler.getSortDirection(colId: col, currentSortColumn: _sortColumn, currentSortAsc: _sortAsc);
      } else {
        _sortColumn = null;
      }
    });
  }

  void _onResizeColumn(String colId, double delta) {
    setState(() {
      _colWidths[colId] = max(80, _colWidths[colId]! + delta);
    });
  }

  bool _isFrozen(String columnId, ProjectState state) {
    if (columnId == 'key' || columnId == 'description' || columnId == 'placeholders') return true;
    if (columnId == 'loc_${state.baseLocale}') return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectControllerProvider);
    final entriesFiltered = ref.watch(filteredEntriesProvider);
    // Get active translating cell once for the whole grid
    final activeTranslatingCell = ref.watch(activeCellTranslationProvider);
    // Get active editing cell
    final editingCell = ref.watch(editingCellProvider);

    _ensureLocaleWidths(state);
    _columnOrder = ['key', 'description', 'placeholders', for (final l in state.locales) 'loc_$l'];

    // Initialize builders with current context
    _cellBuilder = TableCellBuilder(
      ref: ref,
      state: state,
      colWidths: _colWidths,
      selectedKeys: _selectedKeys,
      activeTranslatingCell: activeTranslatingCell,
      editingCell: editingCell,
      onToggleSelection: (key, {required bool add}) => setState(() => _selectedKeys.toggle(key)),
      onShowCellMenu: ({required Offset position, required TranslationEntry entry, required String colId}) {
        String? cellText;

        switch (colId) {
          case 'key':
            cellText = entry.key;
            break;
          case 'description':
            cellText = entry.meta.description ?? '';
            break;
          case 'placeholders':
            cellText = entry.meta.placeholders.join(', ');
            break;
          default:
            if (colId.startsWith('loc_')) {
              final locale = colId.substring(4);
              cellText = entry.values[locale] ?? '';
            }
        }

        _menuHandler.showCellMenu(
          details: TapDownDetails(globalPosition: position),
          key: entry.key,
          colId: colId,
          cellText: cellText,
        );
      },
      horizontalScrollController: _horizontalBody,
    );

    _menuHandler = TableMenuHandler(ref: ref, context: context);

    _headerBuilder = TableHeaderBuilder(
      ref: ref,
      state: state,
      colWidths: _colWidths,
      sortColumn: _sortColumn,
      sortAsc: _sortAsc,
      onCycleSort: _cycleSort,
      onResizeColumn: _onResizeColumn,
    );

    final entries = _sortHandler.sortEntries(entries: entriesFiltered, sortColumn: _sortColumn, sortAsc: _sortAsc);

    // Build frozen + scrollable column id lists
    final frozenCols = [for (final c in _columnOrder.where((c) => _isFrozen(c, state))) c];
    final scrollCols = [for (final c in _columnOrder.where((c) => !_isFrozen(c, state))) c];

    final displayEntries = entries;

    const headerHeight = 40.0;
    const rowHeight = 60.0; // unified fixed row height

    final headerFrozen = _headerBuilder.buildHeaderRow(frozenCols);
    final headerScroll = _headerBuilder.buildHeaderRow(scrollCols);

    final frozenWidth = frozenCols.fold<double>(0, (p, c) => p + _colWidths[c]!);
    final scrollWidth = scrollCols.fold<double>(0, (p, c) => p + _colWidths[c]!);

    final table = Column(
      children: [
        // Header: render scrollable portion via AnimatedBuilder synced to horizontal scroll
        SizedBox(
          height: headerHeight,
          child: Row(
            children: [
              Container(
                width: frozenWidth,
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: Color(0xFF606060), width: 2)),
                ),
                child: ClipRect(child: headerFrozen),
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: _horizontalBody,
                  builder: (context, child) {
                    final offset = _horizontalBody.hasClients ? _horizontalBody.offset : 0.0;
                    return ClipRect(
                      child: OverflowBox(
                        maxWidth: double.infinity,
                        alignment: Alignment.centerLeft,
                        child: Transform.translate(offset: Offset(-offset, 0), child: child),
                      ),
                    );
                  },
                  child: SizedBox(width: scrollWidth, height: headerHeight, child: headerScroll),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Scrollbar(
            controller: _verticalScroll,
            thumbVisibility: true,
            child: ListView.builder(
              controller: _verticalScroll,
              // Always attach a ScrollPosition so that Scrollbar assertion doesn't fire
              // in tests when there are 0 items (empty entries list scenario).
              physics: const AlwaysScrollableScrollPhysics(),
              itemExtent: rowHeight,
              itemCount: displayEntries.length,
              cacheExtent: rowHeight * 20, // Cache 20 rows ahead/behind for smoother scrolling
              addAutomaticKeepAlives: false, // Don't keep alive off-screen items
              addRepaintBoundaries: false, // We manually add RepaintBoundary
              itemBuilder: (c, i) {
                final e = displayEntries[i];
                return RepaintBoundary(
                  key: ValueKey(e.key), // Stable key for better performance
                  child: SizedBox(
                    height: rowHeight,
                    child: Row(
                      children: [
                        // Frozen columns - fixed position
                        Container(
                          width: frozenWidth,
                          decoration: const BoxDecoration(
                            border: Border(right: BorderSide(color: Color(0xFF606060), width: 2)),
                          ),
                          child: ClipRect(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [for (final col in frozenCols) _cellBuilder.buildCell(e, col)],
                            ),
                          ),
                        ),
                        // Scrollable columns - clipped and transformed via AnimatedBuilder
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _horizontalBody,
                            builder: (context, child) {
                              final offset = _horizontalBody.hasClients ? _horizontalBody.offset : 0.0;
                              return ClipRect(
                                child: OverflowBox(
                                  maxWidth: double.infinity,
                                  alignment: Alignment.centerLeft,
                                  child: Transform.translate(offset: Offset(-offset, 0), child: child),
                                ),
                              );
                            },
                            child: SizedBox(
                              width: scrollWidth,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [for (final col in scrollCols) _cellBuilder.buildCell(e, col)],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Bottom horizontal scrollbar controlling body horizontal scroll
        SizedBox(
          height: 14,
          child: Scrollbar(
            controller: _horizontalBody,
            thumbVisibility: true,
            notificationPredicate: (n) => n.metrics.axis == Axis.horizontal,
            child: SingleChildScrollView(
              controller: _horizontalBody,
              scrollDirection: Axis.horizontal,
              // Important: scrollbar width must include frozen columns; otherwise maxScrollExtent
              // is too small and you cannot reach the last locale columns (previously only scrollWidth was used).
              child: SizedBox(width: frozenWidth + scrollWidth + 1, height: 1),
            ),
          ),
        ),
      ],
    );

    final controller = ref.read(projectControllerProvider.notifier);
    return ColoredBox(
      color: AppColors.bgTable,
      child: Shortcuts(
        shortcuts: {
          // Provide fallback Ctrl+S inside grid (unconditional) so widget tests that mount only the grid can still trigger save.
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS): const _GridSaveIntent(),
        },
        child: Actions(
          actions: {
            _GridSaveIntent: CallbackAction<_GridSaveIntent>(
              onInvoke: (intent) {
                controller.saveAll();
                return null;
              },
            ),
          },
          child: Focus(autofocus: true, child: table),
        ),
      ),
    );
  }

  // Stub kept for ProjectPage F2 shortcut compatibility (no-op here)
  void openCurrentRowEditor() {}
}

extension _SetToggle<E> on Set<E> {
  void toggle(E e) {
    contains(e) ? remove(e) : add(e);
  }
}
