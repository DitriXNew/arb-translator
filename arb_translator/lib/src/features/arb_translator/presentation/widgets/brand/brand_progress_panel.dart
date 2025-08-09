import 'package:arb_translator/src/features/arb_translator/presentation/providers/ai_errors_provider.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/project_controller.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/translation_progress_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BrandTranslationProgressPanel extends ConsumerWidget {
  const BrandTranslationProgressPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(translationProgressProvider);
    final errors = ref.watch(aiErrorsProvider);
    if (!progress.isTranslating) return const SizedBox.shrink();
    final pct = progress.total == 0 ? 0 : (progress.done / progress.total * 100).clamp(0, 100).toInt();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Tooltip(
            message: 'AI translation progress',
            child: SizedBox(
              width: 140,
              child: LinearProgressIndicator(
                value: progress.total == 0 ? null : progress.done / progress.total,
                minHeight: 6,
                backgroundColor: Colors.grey.shade800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('${progress.done}/${progress.total} ($pct%)', style: const TextStyle(fontSize: 12)),
          if (errors.isNotEmpty) ...[
            const SizedBox(width: 12),
            Tooltip(
              message: errors.take(5).map((e) => '${e.key} (${e.locale}) - ${e.message}').join('\n'),
              child: Text('Errors: ${errors.length}', style: const TextStyle(fontSize: 12, color: Colors.red)),
            ),
          ],
          const SizedBox(width: 12),
          if (!progress.cancelRequested)
            Tooltip(
              message: 'Cancel AI translation batch',
              child: ElevatedButton(
                onPressed: () => ref.read(projectControllerProvider.notifier).cancelTranslation(),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
                child: const Text('Cancel'),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('Cancelling…', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}
