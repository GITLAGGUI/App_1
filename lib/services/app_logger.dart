import 'package:flutter/foundation.dart';

class AppLogger {
  static void log(String message, {String? tag}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final logTag = tag != null ? '[$tag]' : '[APP]';
      debugPrint('$timestamp $logTag $message');
    }
  }

  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final logTag = tag != null ? '[$tag]' : '[ERROR]';
      debugPrint('$timestamp $logTag $message');
      if (error != null) {
        debugPrint('Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
    }
  }

  static void info(String message, {String? tag}) {
    log(message, tag: tag ?? 'INFO');
  }

  static void warning(String message, {String? tag}) {
    log(message, tag: tag ?? 'WARNING');
  }
}