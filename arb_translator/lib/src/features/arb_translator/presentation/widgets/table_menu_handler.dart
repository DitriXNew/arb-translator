import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Handler for table context menus and translation actions
class TableMenuHandler {
  const TableMenuHandler({required this.ref, required this.context});

  final WidgetRef ref;
  final BuildContext context;

  void showCellMenu({required TapDownDetails details, required String key, required String colId, String? cellText}) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        details.globalPosition.dx + 1,
        details.globalPosition.dy + 1,
      ),
      items: <PopupMenuEntry<String>>[
        // Standard clipboard operations for text cells
        if (colId.startsWith('loc_') || colId == 'key') ...[
          if (cellText != null && cellText.isNotEmpty)
            PopupMenuItem<String>(
              value: 'copy',
              child: const Row(children: [Icon(Icons.copy, size: 16), SizedBox(width: 8), Text('Copy')]),
              onTap: () => _copyToClipboard(cellText),
            ),
          PopupMenuItem<String>(
            value: 'paste',
            child: const Row(children: [Icon(Icons.paste, size: 16), SizedBox(width: 8), Text('Paste')]),
            onTap: () => _pasteFromClipboard(key, colId),
          ),
          const PopupMenuDivider(),
        ],
        // Custom menu items
        if (colId == 'key') ..._buildKeyMenuItems(key),
        if (colId.startsWith('loc_')) ..._buildLocaleMenuItems(key, colId.substring(4)),
      ],
    );
  }

  List<PopupMenuEntry<String>> _buildLocaleMenuItems(String key, String locale) {
    final controller = ref.read(projectControllerProvider.notifier);
    final state = ref.read(projectControllerProvider);
    final isBaseLocale = state.baseLocale == locale;

    if (!isBaseLocale) {
      // For non-English locales: only "Translate this cell"
      return [
        PopupMenuItem<String>(
          value: 'translate_cell',
          child: const Row(children: [Icon(Icons.translate, size: 16), SizedBox(width: 8), Text('Translate')]),
          onTap: () => controller.translateCell(key: key, locale: locale),
        ),
      ];
    } else {
      // For English locale: "Translate this row for all languages"
      return [
        PopupMenuItem<String>(
          value: 'translate_row_all',
          child: const Row(
            children: [
              Icon(Icons.translate, size: 16),
              SizedBox(width: 8),
              Text('Translate this row for all languages'),
            ],
          ),
          onTap: () => _translateRowForAllLanguages(key),
        ),
      ];
    }
  }

  List<PopupMenuEntry<String>> _buildKeyMenuItems(String key) => [
    PopupMenuItem<String>(
      value: 'delete_row',
      child: const Row(
        children: [
          Icon(Icons.delete, size: 16, color: Colors.red),
          SizedBox(width: 8),
          Text('Delete row'),
        ],
      ),
      onTap: () => _confirmDeleteRow(key),
    ),
  ];

  void _confirmDeleteRow(String key) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Row'),
        content: Text('Are you sure you want to delete the key "$key"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              ref.read(projectControllerProvider.notifier).deleteKey(key);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _translateRowForAllLanguages(String key) {
    final controller = ref.read(projectControllerProvider.notifier);
    final state = ref.read(projectControllerProvider);

    // Get all locales except the base locale (English)
    final targetLocales = state.locales.where((locale) => locale != state.baseLocale);

    // Translate for each target locale
    for (final locale in targetLocales) {
      controller.translateCell(key: key, locale: locale);
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  Future<void> _pasteFromClipboard(String key, String colId) async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      final controller = ref.read(projectControllerProvider.notifier);

      if (colId == 'key') {
        final newKey = data!.text!.trim();
        if (newKey.isNotEmpty && newKey != key) {
          controller.renameKey(oldKey: key, newKey: newKey);
        }
      } else if (colId.startsWith('loc_')) {
        final locale = colId.substring(4);
        controller.updateCell(key: key, locale: locale, text: data!.text!);
      }
    }
  }
}
