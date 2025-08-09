import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';

/// Handler for table column sorting functionality
class TableSortHandler {
  const TableSortHandler();

  List<TranslationEntry> sortEntries({
    required List<TranslationEntry> entries,
    required String? sortColumn,
    required bool sortAsc,
  }) {
    if (sortColumn == null) return entries;

    final sorted = List<TranslationEntry>.from(entries);

    switch (sortColumn) {
      case 'key':
        sorted.sort((a, b) => a.key.compareTo(b.key));
        break;
      case 'description':
        sorted.sort((a, b) => (a.meta.description ?? '').compareTo(b.meta.description ?? ''));
        break;
      case 'placeholders':
        sorted.sort((a, b) => a.meta.placeholders.length.compareTo(b.meta.placeholders.length));
        break;
      default:
        if (sortColumn.startsWith('loc_')) {
          final locale = sortColumn.substring(4);
          sorted.sort((a, b) => (a.values[locale] ?? '').compareTo(b.values[locale] ?? ''));
        }
    }

    if (!sortAsc) {
      sorted.reversed.toList();
      return sorted.reversed.toList();
    }

    return sorted;
  }

  String? cycleSortState({required String colId, required String? currentSortColumn, required bool currentSortAsc}) {
    if (currentSortColumn != colId) {
      // Start sorting this column ascending
      return colId;
    } else if (currentSortAsc) {
      // Already sorting ascending, switch to descending
      return colId;
    } else {
      // Already sorting descending, clear sorting
      return null;
    }
  }

  bool getSortDirection({required String colId, required String? currentSortColumn, required bool currentSortAsc}) {
    if (currentSortColumn != colId) {
      return true; // Default to ascending for new sorts
    } else if (currentSortAsc) {
      return false; // Switch to descending
    } else {
      return true; // Switch back to ascending
    }
  }
}
