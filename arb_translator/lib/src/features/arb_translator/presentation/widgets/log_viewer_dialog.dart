import 'package:arb_translator/src/core/services/log_service.dart';
import 'package:arb_translator/src/features/arb_translator/presentation/providers/log_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Debug dialog to view application logs
class LogViewerDialog extends ConsumerWidget {
  const LogViewerDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentLogsAsync = ref.watch(recentLogsProvider);

    return AlertDialog(
      title: const Text('Application Logs'),
      content: SizedBox(
        width: 800,
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(recentLogsProvider);
                  },
                  child: const Text('Refresh'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    await LogService().clearLogs();
                    ref.invalidate(recentLogsProvider);
                  },
                  child: const Text('Clear Logs'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Log file: ${LogService().logFilePath}',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.black87,
                ),
                child: recentLogsAsync.when(
                  data: (logs) => SingleChildScrollView(
                    child: SelectableText(
                      logs.isEmpty ? 'No logs available' : logs,
                      style: const TextStyle(
                        fontFamily: 'Consolas', // Monospace font for logs
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Text('Error loading logs: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
    );
  }

  /// Show the log viewer dialog
  static Future<void> show(BuildContext context) async {
    await showDialog<void>(context: context, builder: (context) => const LogViewerDialog());
  }
}
