import 'dart:developer' as developer;
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;

/// Central logging service for ARB Translator application.
/// Uses both debug.log and file logging for comprehensive debugging.
class LogService {
  factory LogService() => _instance ??= LogService._();
  LogService._();

  static LogService? _instance;

  late final Logger _logger;
  late final File _logFile;
  bool _isInitialized = false;

  /// Initialize the logging service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Create log file in application directory
    final executable = Platform.resolvedExecutable;
    final appDir = Directory(p.dirname(executable));
    final logDir = Directory(p.join(appDir.path, 'logs'));

    if (!logDir.existsSync()) {
      logDir.createSync(recursive: true);
    }

    _logFile = File(p.join(logDir.path, 'arb_translator.log'));

    // Initialize logger with custom output
    _logger = Logger(
      filter: ProductionFilter(),
      printer: PrettyPrinter(dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart),
      output: MultiOutput([ConsoleOutput(), FileOutput(file: _logFile), DebugOutput()]),
    );

    _isInitialized = true;
    info('LogService initialized. Log file: ${_logFile.path}');
  }

  /// Log debug message
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (!_isInitialized) return;
    _logger.d(message, error: error, stackTrace: stackTrace);
    developer.log(message, name: 'ARBTranslator', level: 500);
  }

  /// Log info message
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    if (!_isInitialized) return;
    _logger.i(message, error: error, stackTrace: stackTrace);
    developer.log(message, name: 'ARBTranslator', level: 800);
  }

  /// Log warning message
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    if (!_isInitialized) return;
    _logger.w(message, error: error, stackTrace: stackTrace);
    developer.log(message, name: 'ARBTranslator', level: 900);
  }

  /// Log error message
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (!_isInitialized) return;
    _logger.e(message, error: error, stackTrace: stackTrace);
    developer.log(message, name: 'ARBTranslator', level: 1000);
  }

  /// Log fatal error message
  void fatal(String message, [Object? error, StackTrace? stackTrace]) {
    if (!_isInitialized) return;
    _logger.f(message, error: error, stackTrace: stackTrace);
    developer.log(message, name: 'ARBTranslator', level: 1200);
  }

  /// Get log file path
  String get logFilePath => _logFile.path;

  /// Get recent log entries from file
  Future<String> getRecentLogs([int lines = 100]) async {
    if (!_logFile.existsSync()) return 'No log file found';

    final content = await _logFile.readAsString();
    final logLines = content.split('\n');

    if (logLines.length <= lines) return content;

    return logLines.skip(logLines.length - lines).join('\n');
  }

  /// Clear log file
  Future<void> clearLogs() async {
    if (_logFile.existsSync()) {
      await _logFile.writeAsString('');
      info('Log file cleared');
    }
  }
}

/// Custom file output for logger
class FileOutput extends LogOutput {
  FileOutput({required this.file});
  final File file;

  @override
  void output(OutputEvent event) {
    final buffer = StringBuffer();
    for (final line in event.lines) {
      buffer.writeln('${DateTime.now().toIso8601String()} $line');
    }

    // Append to file asynchronously
    file.writeAsString(buffer.toString(), mode: FileMode.append).catchError((Object e) => file);
  }
}

/// Debug output using developer.log
class DebugOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      developer.log(line, name: 'ARBTranslator');
    }
  }
}

/// Global logging functions for convenience
void logDebug(String message, [Object? error, StackTrace? stackTrace]) {
  LogService().debug(message, error, stackTrace);
}

void logInfo(String message, [Object? error, StackTrace? stackTrace]) {
  LogService().info(message, error, stackTrace);
}

void logWarning(String message, [Object? error, StackTrace? stackTrace]) {
  LogService().warning(message, error, stackTrace);
}

void logError(String message, [Object? error, StackTrace? stackTrace]) {
  LogService().error(message, error, stackTrace);
}

void logFatal(String message, [Object? error, StackTrace? stackTrace]) {
  LogService().fatal(message, error, stackTrace);
}
