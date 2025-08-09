import 'package:arb_translator/src/features/arb_translator/domain/entities/translation_entry.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Derived provider giving the filtered list of entries based on current flags.
final filteredEntriesProvider = Provider<List<TranslationEntry>>((ref) {
  final state = ref.watch(projectControllerProvider);
  var list = state.entries;

  // Apply search filter
  if (state.searchQuery.isNotEmpty) {
    final query = state.searchQuery.toLowerCase();
    list = list.where((e) {
      // Search in key
      if (e.key.toLowerCase().contains(query)) return true;

      // Search in description
      final desc = e.meta.description?.toLowerCase() ?? '';
      if (desc.contains(query)) return true;

      // Search in base locale (English) value
      final baseValue = e.values[state.baseLocale]?.toLowerCase() ?? '';
      if (baseValue.contains(query)) return true;

      return false;
    }).toList();
  }

  if (state.showOnlyErrors) {
    final errorKeys = state.errorCells.map((e) => e.$1).toSet();
    list = list.where((e) => errorKeys.contains(e.key)).toList();
  }
  if (state.showOnlyUntranslated) {
    list = list.where((e) {
      for (final l in state.locales) {
        if (l == state.baseLocale) continue;
        final v = e.values[l] ?? '';
        if (v.isEmpty) return true;
      }
      return false;
    }).toList();
  }
  return list;
});
