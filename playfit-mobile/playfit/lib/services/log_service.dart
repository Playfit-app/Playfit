import 'dart:collection';

import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class LogEntry {
  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
  });

  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  String get formattedTimestamp {
    final hh = timestamp.hour.toString().padLeft(2, '0');
    final mm = timestamp.minute.toString().padLeft(2, '0');
    final ss = timestamp.second.toString().padLeft(2, '0');
    final ms = timestamp.millisecond.toString().padLeft(3, '0');
    return '$hh:$mm:$ss.$ms';
  }

  @override
  String toString() {
    final buffer = StringBuffer()
      ..write('[$formattedTimestamp] ${level.name.toUpperCase()} ')
      ..write(message);
    if (error != null) {
      buffer..write(' | error: ')..write(error);
    }
    if (stackTrace != null) {
      buffer..write('\n')..write(stackTrace);
    }
    return buffer.toString();
  }
}

class LogService {
  LogService._internal();

  static final LogService _instance = LogService._internal();
  static LogService get instance => _instance;

  static const int _maxEntries = 500;

  final ValueNotifier<List<LogEntry>> _entries =
      ValueNotifier<List<LogEntry>>(<LogEntry>[]);

  ValueListenable<List<LogEntry>> get entries => _entries;

  void log(
    String message, {
    LogLevel level = LogLevel.debug,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );

    final updated = List<LogEntry>.from(_entries.value)..add(entry);
    if (updated.length > _maxEntries) {
      updated.removeRange(0, updated.length - _maxEntries);
    }
    _entries.value = UnmodifiableListView(updated);

    debugPrint(entry.toString());
  }

  void clear() {
    _entries.value = const <LogEntry>[];
  }
}
