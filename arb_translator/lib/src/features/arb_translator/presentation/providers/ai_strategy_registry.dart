import 'package:arb_translator/src/features/arb_translator/data/ai/mock_strategy.dart';
import 'package:arb_translator/src/features/arb_translator/data/ai/offline_strategy.dart';
import 'package:arb_translator/src/features/arb_translator/domain/ai/ai_strategy_ids.dart';
import 'package:arb_translator/src/features/arb_translator/domain/ai/ai_translation_strategy.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Registry holding all available AI translation strategies.
/// For now only OpenAI, but designed for future expansion.
class AiStrategyEntry {
  const AiStrategyEntry({required this.id, required this.label});
  final String id;
  final String label;
}

// Single strategy for now.
final aiStrategyRegistryProvider = Provider<List<AiStrategyEntry>>(
  (ref) => const [
    AiStrategyEntry(id: AiStrategyIds.openAi, label: 'OpenAI'),
    AiStrategyEntry(id: AiStrategyIds.mock, label: 'Mock'),
    AiStrategyEntry(id: AiStrategyIds.offline, label: 'Offline'),
  ],
);

/// Selected strategy id (persist in memory only for now).
class SelectedAiStrategyId extends Notifier<String> {
  static const _prefsKey = 'selected_ai_strategy_id';
  Future<SharedPreferences>? _loading;

  @override
  String build() {
    _loading = SharedPreferences.getInstance();
    _loading!.then((prefs) {
      final saved = prefs.getString(_prefsKey);
      if (saved != null && saved.isNotEmpty) {
        final all = ref.read(aiStrategyRegistryProvider).map((e) => e.id).toSet();
        if (all.contains(saved) && state != saved) state = saved;
      }
    });
    return AiStrategyIds.openAi;
  }

  Future<void> select(String id) async {
    state = id;
    try {
      final prefs = await (_loading ??= SharedPreferences.getInstance());
      await prefs.setString(_prefsKey, id);
    } catch (_) {}
  }
}

final selectedAiStrategyIdProvider = NotifierProvider<SelectedAiStrategyId, String>(SelectedAiStrategyId.new);

/// Resolves current strategy instance from selection.
final currentAiStrategyProvider = Provider<AiTranslationStrategy>((ref) {
  final id = ref.watch(selectedAiStrategyIdProvider);
  switch (id) {
    case AiStrategyIds.openAi:
      return ref.watch(aiStrategyProvider);
    case AiStrategyIds.mock:
      return const MockTranslationStrategy();
    case AiStrategyIds.offline:
      return const OfflinePassthroughStrategy();
    default:
      return ref.watch(aiStrategyProvider); // fallback
  }
});
