import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class DebugModeFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return kDebugMode;
  }
}

final Logger _internalLogger = Logger(
  filter: DebugModeFilter(),
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    stackTraceBeginIndex: 1,
  ),
);

class AppLogger {
  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _internalLogger.d(message, error: error, stackTrace: stackTrace);
  }

  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _internalLogger.i(message, error: error, stackTrace: stackTrace);
  }

  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _internalLogger.w(message, error: error, stackTrace: stackTrace);
  }

  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _internalLogger.e(message, error: error, stackTrace: stackTrace);
  }
}

final AppLogger appLogger = AppLogger();
