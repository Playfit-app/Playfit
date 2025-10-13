import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

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
      buffer
        ..write(' | error: ')
        ..write(error);
    }
    if (stackTrace != null) {
      buffer
        ..write('\n')
        ..write(stackTrace);
    }
    return buffer.toString();
  }
}

class LogService {
  LogService._({
    String? logFileName,
    bool keepInMemory = true,
    bool persistToFile = true,
    int maxEntries = _defaultMaxEntries,
    Future<Directory> Function()? logDirectoryBuilder,
    bool enabled = !kReleaseMode,
  })  : _logFileName = persistToFile ? _normalizeFileName(logFileName) : null,
        _keepEntriesInMemory = keepInMemory,
        _persistToFile = persistToFile,
        _maxEntries = maxEntries,
        _enabled = enabled,
        _logDirectoryBuilder =
            logDirectoryBuilder ?? _defaultLogDirectoryBuilder;

  factory LogService({
    String? logFileName,
    bool keepInMemory = true,
    bool persistToFile = true,
    int maxEntries = _defaultMaxEntries,
    bool enabled = !kReleaseMode,
  }) {
    return LogService._(
      logFileName: logFileName,
      keepInMemory: keepInMemory,
      persistToFile: persistToFile,
      maxEntries: maxEntries,
      enabled: enabled,
    );
  }

  static final LogService _instance = LogService._();
  static LogService get instance => _instance;

  static const int _defaultMaxEntries = 500;
  static const int _maxPendingFileWrites = 200;
  static const String _defaultLogFileName = 'general.log';

  final bool _keepEntriesInMemory;
  final bool _persistToFile;
  final int _maxEntries;
  final bool _enabled;
  String? _logFileName;
  final Future<Directory> Function() _logDirectoryBuilder;

  final ValueNotifier<List<LogEntry>> _entries =
      ValueNotifier<List<LogEntry>>(<LogEntry>[]);

  ValueListenable<List<LogEntry>> get entries => _entries;

  IOSink? _fileSink;
  Future<void>? _fileInitialization;
  final Queue<String> _pendingFileWrites = Queue<String>();

  void log(
    String message, {
    LogLevel level = LogLevel.debug,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled) {
      return;
    }

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );

    if (_keepEntriesInMemory) {
      final updated = List<LogEntry>.from(_entries.value)..add(entry);
      if (updated.length > _maxEntries) {
        updated.removeRange(0, updated.length - _maxEntries);
      }
      _entries.value = UnmodifiableListView(updated);
    }

    debugPrint(entry.toString());

    if (_persistToFile && !kIsWeb && _logFileName != null) {
      _writeToFile(entry);
    }
  }

  Future<void> useLogFile({String? fileName}) async {
    if (!_persistToFile) {
      return;
    }

    final normalized = _normalizeFileName(fileName);
    if (_logFileName == normalized) {
      return;
    }

    await _closeFileSink();
    _logFileName = normalized;
  }

  Future<String?> currentLogFilePath() async {
    if (!_persistToFile || kIsWeb || _logFileName == null) {
      return null;
    }

    try {
      final directory = await _logDirectoryBuilder();
      return _joinPaths(directory.path, _logFileName!);
    } catch (_) {
      return null;
    }
  }

  Future<void> flush() async {
    final sink = _fileSink;
    if (sink == null) {
      return;
    }
    try {
      await sink.flush();
    } catch (_) {
      // Ignore flush failures; they will be retried on the next write attempt.
    }
  }

  Future<void> dispose() async {
    await _closeFileSink();
  }

  void clear() {
    if (_keepEntriesInMemory) {
      _entries.value = const <LogEntry>[];
    }
  }

  void _writeToFile(LogEntry entry) {
    final payload = entry.toString();
    final sink = _fileSink;
    if (sink != null) {
      try {
        sink.writeln(payload);
        unawaited(sink.flush());
        return;
      } catch (error, stackTrace) {
        _handleFileWriteFailure(error, stackTrace, payload: payload);
        return;
      }
    }

    _enqueuePendingWrite(payload);
  }

  void _enqueuePendingWrite(String payload) {
    if (_pendingFileWrites.length >= _maxPendingFileWrites) {
      _pendingFileWrites.removeFirst();
    }
    _pendingFileWrites.addLast(payload);
    _ensureFileSinkInitialized();
  }

  void _ensureFileSinkInitialized() {
    if (_fileInitialization != null || _logFileName == null) {
      return;
    }
    _fileInitialization = _openFileSink().whenComplete(() {
      _fileInitialization = null;
    });
  }

  Future<void> _openFileSink() async {
    final fileName = _logFileName;
    if (fileName == null) {
      return;
    }

    try {
      final directory = await _logDirectoryBuilder();
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final file = File(_joinPaths(directory.path, fileName));
      _fileSink = file.openWrite(mode: FileMode.writeOnlyAppend);

      while (_pendingFileWrites.isNotEmpty) {
        final pending = _pendingFileWrites.removeFirst();
        _fileSink!.writeln(pending);
      }

      await _fileSink!.flush();
    } catch (error, stackTrace) {
      _handleFileWriteFailure(error, stackTrace);
    }
  }

  Future<void> _closeFileSink() async {
    final sink = _fileSink;
    if (sink == null) {
      return;
    }

    _fileSink = null;
    try {
      await sink.flush();
    } catch (_) {
      // ignore flush failure during close
    }
    await sink.close();
  }

  void _handleFileWriteFailure(
    Object error,
    StackTrace stackTrace, {
    String? payload,
  }) {
    if (kDebugMode) {
      debugPrint(
        'LogService: failed to write to log file '
        '${_logFileName ?? 'unknown'}: $error',
      );
      debugPrint(stackTrace.toString());
    }

    if (payload != null) {
      _enqueuePendingWrite(payload);
    }

    unawaited(_closeFileSink());
  }

  static String _normalizeFileName(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return _defaultLogFileName;
    }
    return trimmed.replaceAll(RegExp(r'[\\/]+'), '_');
  }

  static Future<Directory> _defaultLogDirectoryBuilder() async {
    try {
      final supportDir = await getApplicationSupportDirectory();
      return Directory(_joinPaths(supportDir.path, 'logs'));
    } catch (_) {
      return Directory(_joinPaths(Directory.systemTemp.path, 'playfit_logs'));
    }
  }

  static String _joinPaths(String parent, String child) {
    if (parent.isEmpty) {
      return child;
    }
    final separator = Platform.pathSeparator;
    if (parent.endsWith(separator)) {
      return '$parent$child';
    }
    return '$parent$separator$child';
  }
}
