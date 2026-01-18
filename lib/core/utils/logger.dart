import 'package:flutter/foundation.dart';

class AppLogger {
  // ANSI Color Codes
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _cyan = '\x1B[36m';

  static void info(String source, String message) {
    if (kDebugMode) {
      debugPrint('''
$_cyan╔════════════════════════════════════════════════════════════════════════════
║ ℹ️ INFO from [$source]
╠════════════════════════════════════════════════════════════════════════════
║ $message
╚════════════════════════════════════════════════════════════════════════════$_reset
''');
    }
  }

  static void success(String source, String message) {
    if (kDebugMode) {
      debugPrint('''
$_green╔════════════════════════════════════════════════════════════════════════════
║ ✅ SUCCESS from [$source]
╠════════════════════════════════════════════════════════════════════════════
║ $message
╚════════════════════════════════════════════════════════════════════════════$_reset
''');
    }
  }

  static void warning(String source, String message) {
    if (kDebugMode) {
      debugPrint('''
$_yellow╔════════════════════════════════════════════════════════════════════════════
║ ⚠️ WARNING from [$source]
╠════════════════════════════════════════════════════════════════════════════
║ $message
╚════════════════════════════════════════════════════════════════════════════$_reset
''');
    }
  }

  static void error(String source, String message,
      {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      final errorStr = error != null ? '\n║ Error: $error' : '';
      final stackStr = stackTrace != null ? '\n║ StackTrace:\n$stackTrace' : '';

      debugPrint('''
$_red╔════════════════════════════════════════════════════════════════════════════
║ ⛔ ERROR from [$source]
╠════════════════════════════════════════════════════════════════════════════
║ Message: $message$errorStr$stackStr
╚════════════════════════════════════════════════════════════════════════════$_reset
''');
    }
  }
}
