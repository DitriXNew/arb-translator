import 'package:arb_translator/src/core/services/log_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod provider for LogService
final logServiceProvider = Provider<LogService>((ref) => LogService());

/// Provider for accessing recent logs (useful for debug UI)
final recentLogsProvider = FutureProvider<String>((ref) async {
  final logService = ref.watch(logServiceProvider);
  return logService.getRecentLogs(50); // Last 50 lines
});
