// lib/core/logs.dart
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

// Helper to get current time
String get _timestamp => DateFormat('HH:mm:ss').format(DateTime.now());

/// usage: debug("Fetching polls...");
void debug(dynamic message) {
  if (kDebugMode) {
    // \x1B[34m is Blue color code for terminals that support it
    print('$_timestamp 🔵 [DEBUG]   $message');
  }
}

/// usage: warning("Token is empty");
void warning(dynamic message) {
  // \x1B[33m is Yellow
  print('$_timestamp 🟠 [WARNING] $message');
}

/// usage: error(e);
void error(dynamic message, [StackTrace? stackTrace]) {
  // \x1B[31m is Red
  print('$_timestamp 🔴 [ERROR]   $message');
  if (stackTrace != null) {
    print(stackTrace);
  }
}
