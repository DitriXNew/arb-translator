import 'dart:io';
import 'package:arb_translator/src/core/services/log_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart' show Level, LogEvent, OutputEvent;
import 'package:path/path.dart' as p;

void main() {
  group('LogService', () {
    late Directory tempDir;
    late LogService logService;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('arb_translator_test_logs');
      logService = LogService();
      await logService.initialize();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('initializes and creates log file', () async {
      // LogService initializes correctly
      expect(logService.logFilePath, isNotEmpty);
    });

    test('singleton pattern works', () {
      final service1 = LogService();
      final service2 = LogService();
      expect(identical(service1, service2), isTrue);
    });

    test('logging methods work without errors', () {
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      expect(() => logService.debug('Debug message'), returnsNormally);
      expect(() => logService.info('Info message'), returnsNormally);
      expect(() => logService.warning('Warning message'), returnsNormally);
      expect(() => logService.error('Error message'), returnsNormally);
      expect(() => logService.fatal('Fatal message'), returnsNormally);

      // With error and stack trace
      expect(() => logService.debug('Debug with details', error, stackTrace), returnsNormally);
      expect(() => logService.info('Info with error', error), returnsNormally);
      expect(() => logService.error('Error with details', error, stackTrace), returnsNormally);
      expect(() => logService.warning('Warning with error', error), returnsNormally);
    });

    test('global logging functions work', () {
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      expect(() => logDebug('Debug message'), returnsNormally);
      expect(() => logInfo('Info message'), returnsNormally);
      expect(() => logWarning('Warning message'), returnsNormally);
      expect(() => logError('Error message'), returnsNormally);
      expect(() => logFatal('Fatal message'), returnsNormally);

      // With error and stack trace
      expect(() => logDebug('Debug with details', error, stackTrace), returnsNormally);
      expect(() => logInfo('Info with error', error), returnsNormally);
      expect(() => logError('Error with details', error, stackTrace), returnsNormally);
      expect(() => logWarning('Warning with error', error), returnsNormally);
    });

    test('getRecentLogs returns string', () async {
      // Since the log file might not exist in test environment
      final recentLogs = await logService.getRecentLogs(10);
      expect(recentLogs, isA<String>());
    });

    test('clearLogs completes', () async {
      await expectLater(logService.clearLogs(), completes);
    });
  });

  group('FileOutput', () {
    test('appends each line with a timestamp', () async {
      final dir = Directory.systemTemp.createTempSync('file_output_test');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = File(p.join(dir.path, 'log.txt'));

      FileOutput(file: file).output(OutputEvent(LogEvent(Level.info, 'm'), ['first line', 'second line']));

      // The append is fire-and-forget; wait for it to land.
      for (var i = 0; i < 50 && !(file.existsSync() && file.readAsStringSync().contains('second line')); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      final lines = file.readAsLinesSync();
      expect(lines, hasLength(2));
      expect(lines.first, matches(RegExp(r'^\d{4}-\d{2}-\d{2}T\S+ first line$')));
    });
  });
}
