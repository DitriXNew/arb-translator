import 'package:arb_translator/src/core/theme/color_tokens.dart';
import 'package:arb_translator/src/core/theme/spacing.dart';
import 'package:arb_translator/src/core/theme/text_styles.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_settings_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_strategy_registry.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/notifications_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_controller.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/widgets/log_viewer_dialog.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Main top toolbar with folder select and quick actions.

class ProjectToolbar extends ConsumerWidget {
  const ProjectToolbar({super.key});

  Future<void> _pickFolder(WidgetRef ref) async => getDirectoryPath().then((path) async {
    if (path == null) return;
    await ref.read(projectControllerProvider.notifier).loadFolder(path);
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(projectControllerProvider);
    final controller = ref.read(projectControllerProvider.notifier);
    final hasFolder = state.folderPath != null;
    final accent = Theme.of(context).colorScheme.primary;
    Widget iconBtn({required IconData icon, required String tooltip, required VoidCallback? onPressed, Color? fg}) =>
        Tooltip(
          message: tooltip,
          child: IconButton(
            icon: Icon(icon, size: 20, color: fg),
            onPressed: onPressed,
          ),
        );
    final row = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          iconBtn(icon: Icons.folder_open, tooltip: 'Select ARB folder', onPressed: () => _pickFolder(ref), fg: accent),
          const SizedBox(width: AppSpacing.xs),
          if (hasFolder)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(state.folderPath!, overflow: TextOverflow.ellipsis, style: AppTextStyles.caption11),
            ),
          if (state.isLoading) ...[
            const SizedBox(width: AppSpacing.s),
            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          ],
          const SizedBox(width: AppSpacing.s),
          // Filters
          IconButton(
            tooltip: state.showOnlyErrors ? 'Show all rows' : 'Filter: only rows with placeholder errors',
            onPressed: hasFolder ? controller.toggleFilterErrors : null,
            icon: Icon(Icons.shield, size: 18, color: state.showOnlyErrors ? accent : AppColors.textPrimary),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            tooltip: state.showOnlyUntranslated ? 'Show all rows' : 'Filter: only untranslated cells',
            onPressed: hasFolder ? controller.toggleFilterUntranslated : null,
            icon: Icon(Icons.translate, size: 18, color: state.showOnlyUntranslated ? accent : AppColors.textPrimary),
          ),
          const SizedBox(width: AppSpacing.xs),
          Tooltip(
            message: 'Remove keys missing in English (orphan keys from other locales)',
            child: IconButton(
              icon: const Icon(Icons.cleaning_services, size: 18),
              onPressed: hasFolder
                  ? () async {
                      final orphanCount = state.entries.where((e) {
                        final enVal = (e.values[state.baseLocale] ?? '').trim();
                        final missingInBase = state.baseLocaleKeys.isNotEmpty && !state.baseLocaleKeys.contains(e.key);
                        return missingInBase || enVal.isEmpty;
                      }).length;
                      if (orphanCount == 0) {
                        // Always delegate to controller so it can log & notify consistently.
                        controller.removeKeysMissingInEnglish();
                        return;
                      }
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Confirm cleanup'),
                          content: Text(
                            'Remove $orphanCount orphan key(s) that are missing from English? This cannot be undone except via Undo stack.',
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove')),
                          ],
                        ),
                      );
                      if (confirmed ?? false) controller.removeKeysMissingInEnglish();
                    }
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Tooltip(
            message: 'Remove keys with empty English value',
            child: IconButton(
              icon: const Icon(Icons.filter_alt_off, size: 18),
              onPressed: hasFolder
                  ? () async {
                      final emptyCount = state.entries
                          .where((e) => (e.values[state.baseLocale] ?? '').trim().isEmpty)
                          .length;
                      if (emptyCount == 0) {
                        controller.removeKeysWithEmptyEnglish();
                        return;
                      }
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Confirm removal'),
                          content: Text('Remove $emptyCount key(s) whose English value is empty?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove')),
                          ],
                        ),
                      );
                      if (confirmed ?? false) controller.removeKeysWithEmptyEnglish();
                    }
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.l),
          // Undo / Redo
          iconBtn(icon: Icons.undo, tooltip: 'Undo (Ctrl+Z)', onPressed: hasFolder ? controller.undo : null),
          iconBtn(icon: Icons.redo, tooltip: 'Redo (Ctrl+Y)', onPressed: hasFolder ? controller.redo : null),
          const SizedBox(width: AppSpacing.s),
          IconButton(
            tooltip: 'AI Settings (API key & glossary prompt)',
            icon: const Icon(Icons.settings, size: 20),
            onPressed: () => _showAiSettingsDialog(context, ref),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            tooltip: 'View Application Logs (Debug)',
            icon: const Icon(Icons.bug_report, size: 20),
            onPressed: () => LogViewerDialog.show(context),
          ),
          const SizedBox(width: AppSpacing.s),
          // Strategy selector
          _StrategySelector(),
          const SizedBox(width: AppSpacing.s),
          ElevatedButton.icon(
            onPressed: hasFolder && state.hasUnsavedChanges && !state.isSaving ? controller.saveAll : null,
            icon: const Icon(Icons.save, size: 16),
            label: const Text('Save'),
          ),
        ],
      ),
    );
    return row;
  }

  void _showAiSettingsDialog(BuildContext context, WidgetRef ref) {
    final settings = ref.read(aiSettingsProvider);
    final selectedStrategy = ref.read(selectedAiStrategyIdProvider);
    final keyController = TextEditingController();
    final glossaryController = TextEditingController(text: settings.glossaryPrompt);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('AI Settings'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('API Key (stored securely, masked after save)', style: AppTextStyles.body13),
                const SizedBox(height: 4),
                if (settings.apiKeyMasked != null)
                  Text('Current: ${settings.apiKeyMasked}', style: AppTextStyles.caption11),
                TextField(
                  controller: keyController,
                  decoration: const InputDecoration(hintText: 'sk-...'),
                  obscureText: true,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final v = keyController.text.trim();
                        if (v.isEmpty) return;

                        final valid = v.startsWith('sk-') && v.length > 20;
                        if (!valid) {
                          ref.read(notificationMessageProvider.notifier).message = 'Invalid API key format';
                          return;
                        }

                        try {
                          // Show loading state
                          ref.read(notificationMessageProvider.notifier).message = 'Validating API key...';

                          // Validate by fetching models
                          final models = await ref.read(aiSettingsProvider.notifier).validateApiKey(v);

                          // Save if validation successful
                          await ref.read(aiSettingsProvider.notifier).setApiKey(v);
                          keyController.clear();

                          // Show success with model count
                          ref.read(notificationMessageProvider.notifier).message =
                              'API key saved successfully! Found ${models.length} available models.';
                        } catch (e) {
                          // Show error
                          ref.read(notificationMessageProvider.notifier).message =
                              'API key validation failed: ${e.toString().replaceAll('Exception: ', '')}';
                        }
                      },
                      child: const Text('Save Key'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: settings.apiKeyMasked != null
                          ? () async {
                              await ref.read(aiSettingsProvider.notifier).clearApiKey();
                              ref.read(notificationMessageProvider.notifier).message = 'API key cleared';
                            }
                          : null,
                      child: const Text('Clear Key'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Glossary / Terminology Prompt (optional)', style: AppTextStyles.body13),
                const SizedBox(height: 4),
                TextField(
                  controller: glossaryController,
                  maxLines: 5,
                  decoration: const InputDecoration(hintText: 'List important product names...'),
                ),
                const SizedBox(height: 16),
                if (selectedStrategy == 'openai')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Legacy info line kept for clarity.
                      Text('Using model ${settings.openAiModel} (fixed)', style: AppTextStyles.caption11),
                    ],
                  )
                else
                  const Text('Model settings disabled', style: AppTextStyles.caption11),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final text = glossaryController.text;
              Navigator.pop(ctx);
              await ref.read(aiSettingsProvider.notifier).setGlossaryPrompt(text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _StrategySelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(aiStrategyRegistryProvider);
    final selected = ref.watch(selectedAiStrategyIdProvider);
    return DropdownButton<String>(
      value: selected,
      hint: const Text('AI Strategy'),
      underline: const SizedBox.shrink(),
      items: [
        for (final e in entries)
          DropdownMenuItem<String>(
            value: e.id,
            child: Row(
              children: [
                if (e.id == 'mock') const Icon(Icons.science, size: 14),
                if (e.id == 'offline') const Icon(Icons.offline_bolt, size: 14),
                const SizedBox(width: 4),
                Text(e.label, style: AppTextStyles.caption11),
              ],
            ),
          ),
      ],
      onChanged: (v) {
        if (v != null) {
          ref.read(selectedAiStrategyIdProvider.notifier).select(v);
        }
      },
    );
  }
}

// Removed _ModelField and _TemperatureSlider (model & temperature fixed). Kept comment stub for future reinstatement if needed.
