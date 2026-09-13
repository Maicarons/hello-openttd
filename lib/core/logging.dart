import 'dart:io';

import 'package:path/path.dart' as p;

/// Minimal rolling file logger (per-day files, `info`/`debug` levels).
///
/// Kept dependency-free on purpose; all failures are swallowed so logging
/// never breaks the app.
class Log {
  Log._();

  static IOSink? _sink;
  static String? _currentFile;
  static Level _level = Level.info;

  static void _open(Directory dir) {
    try {
      if (!dir.existsSync()) dir.createSync(recursive: true);
      _prune(dir);
      final name = 'hello-openttd-${DateTime.now().toIso8601String().substring(0, 10)}.log';
      final file = File(p.join(dir.path, name));
      _sink = file.openWrite(mode: FileMode.append);
      _currentFile = file.path;
    } catch (_) {
      _sink = null;
    }
  }

  /// Keeps the last 14 log files.
  static void _prune(Directory dir) {
    final files = dir.listSync().whereType<File>().toList()
      ..sort((a, b) => b.path.compareTo(a.path));
    for (final f in files.skip(14)) {
      try {
        f.deleteSync();
      } catch (_) {}
    }
  }

  static void write(Level level, String message, [Object? error, StackTrace? stack]) {
    if (level == Level.debug && _level == Level.info) return;
    final line =
        '${DateTime.now().toIso8601String()} [${level.name.toUpperCase()}] $message'
        '${error != null ? ' — $error' : ''}'
        '${stack != null ? '\n$stack' : ''}';
    try {
      _sink?.writeln(line);
      _sink?.flush();
    } catch (_) {}
    assert(() {
      // ignore: avoid_print
      print(line);
      return true;
    }());
  }

  static void info(String message) => write(Level.info, message);
  static void debug(String message) => write(Level.debug, message);
  static void error(String message, [Object? error, StackTrace? stack]) =>
      write(Level.info, message, error, stack);

  static String? get currentLogFile => _currentFile;
}

enum Level { info, debug }

/// Redacts token-like strings before anything is written to the log.
String redact(String input) => input
    .replaceAllMapped(RegExp(r'gh[pousr]_[A-Za-z0-9]{20,}'), (_) => '<redacted>')
    .replaceAllMapped(RegExp(r'github_pat_[A-Za-z0-9_]{20,}'), (_) => '<redacted>')
    .replaceAllMapped(
        RegExp('bearer\\s+[A-Za-z0-9._-]{10,}', caseSensitive: false),
        (_) => 'Bearer <redacted>');

void initLogging(Directory logsDir) {
  Log._open(logsDir);
}
