import 'package:arb_translator/src/features/arb_translator/presentation/providers/filtered_entries_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/notifications_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_controller.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_state.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/undo_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/widgets/grid.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/widgets/search_bar.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/widgets/toolbar.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectPage extends ConsumerStatefulWidget {
  const ProjectPage({super.key});

  @override
  ConsumerState<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends ConsumerState<ProjectPage> {
  final _gridKey = GlobalKey<TranslationGridState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectControllerProvider);
    final controller = ref.read(projectControllerProvider.notifier);
    final undoMgr = ref.watch(undoManagerProvider);

    // Listen for successful save events and show SnackBar
    ref.listen<ProjectState>(projectControllerProvider, (previous, next) {
      if (previous?.lastSavedAt != next.lastSavedAt && next.lastSavedAt != null) {
        // Show success SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Saved successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });

    // Listen for notification messages and show SnackBar
    ref.listen<String?>(notificationMessageProvider, (previous, next) {
      if (next != null && next.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
        // Clear the message after showing
        Future.microtask(() => ref.read(notificationMessageProvider.notifier).clearMessage());
      }
    });

    // Define intents
    final shortcuts = <LogicalKeySet, Intent>{
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS): const _SaveIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyZ): const _UndoIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyY): const _RedoIntent(),
      LogicalKeySet(LogicalKeyboardKey.f2): const _OpenEditorIntent(),
    };
    final actions = <Type, Action<Intent>>{
      _SaveIntent: CallbackAction<_SaveIntent>(
        onInvoke: (_) {
          if (state.hasUnsavedChanges && !state.isSaving) controller.saveAll();
          return null;
        },
      ),
      _UndoIntent: CallbackAction<_UndoIntent>(
        onInvoke: (_) {
          if (undoMgr.canUndo) controller.undo();
          return null;
        },
      ),
      _RedoIntent: CallbackAction<_RedoIntent>(
        onInvoke: (_) {
          if (undoMgr.canRedo) controller.redo();
          return null;
        },
      ),
      _OpenEditorIntent: CallbackAction<_OpenEditorIntent>(
        onInvoke: (_) {
          _gridKey.currentState?.openCurrentRowEditor();
          return null;
        },
      ),
    };

    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: actions,
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text('ARB Translator'),
              toolbarHeight: 60,
              backgroundColor: const Color(0xFF161719),
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  alignment: Alignment.centerLeft,
                  child: const ProjectToolbar(),
                ),
              ),
            ),
            body: Column(
              children: [
                // Search bar - only show when there are entries
                if (state.entries.isNotEmpty) const TranslationSearchBar(),
                Expanded(
                  child: state.entries.isEmpty
                      ? const _EmptyState()
                      : Padding(
                          padding: const EdgeInsets.all(4),
                          child: TranslationGrid(key: _gridKey),
                        ),
                ),
                const _StatusBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SaveIntent extends Intent {
  const _SaveIntent();
}

class _UndoIntent extends Intent {
  const _UndoIntent();
}

class _RedoIntent extends Intent {
  const _RedoIntent();
}

class _OpenEditorIntent extends Intent {
  const _OpenEditorIntent();
}

class _EmptyState extends ConsumerWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context, WidgetRef ref) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.folder_open, size: 72, color: Color(0x88FFFFFF)),
        const SizedBox(height: 16),
        const Text('Select a folder to start', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Text(
          'Open an ARB folder to load locales and begin translating.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            final path = await getDirectoryPath();
            if (path != null) {
              await ref.read(projectControllerProvider.notifier).loadFolder(path);
            }
          },
          child: const Text('Choose folder'),
        ),
      ],
    ),
  );
}

class _StatusBar extends ConsumerWidget {
  const _StatusBar();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(projectControllerProvider);
    final filteredEntries = ref.watch(filteredEntriesProvider);
    final total = state.entries.length;
    final filtered = filteredEntries.length;
    final filteredErrorsKeys = state.errorCells.map((e) => e.$1).toSet();
    final errors = filteredErrorsKeys.length;
    final untranslated = state.entries.where((e) {
      for (final l in state.locales) {
        if (l == state.baseLocale) continue;
        if ((e.values[l] ?? '').isEmpty) return true;
      }
      return false;
    }).length;
    final dirty = state.dirtyCells.length;
    final sourceChanged = state.sourceChangedKeys.length;
    final hasFilters = state.searchQuery.isNotEmpty || state.showOnlyErrors || state.showOnlyUntranslated;
    return Container(
      height: 26,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF333333))),
        color: Color(0xFF1E1E1E),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 24,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (hasFilters) ...[_Stat('Showing', filtered), _Stat('of', total)] else _Stat('Rows', total),
          _Stat('Errors', errors),
          _Stat('Untranslated', untranslated),
          _Stat('Dirty cells', dirty),
          if (sourceChanged > 0) _StatWithColor('Source changed', sourceChanged, Colors.orange),
          if (state.searchQuery.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search, size: 12, color: Color(0xFFAAAAAA)),
                const SizedBox(width: 2),
                Text(
                  '"${state.searchQuery}"',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF0078D4), fontStyle: FontStyle.italic),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA))),
      const SizedBox(width: 4),
      Text('$value', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11)),
    ],
  );
}

class _StatWithColor extends StatelessWidget {
  const _StatWithColor(this.label, this.value, this.color);
  final String label;
  final int value;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA))),
      const SizedBox(width: 4),
      Text(
        '$value',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: color),
      ),
    ],
  );
}
