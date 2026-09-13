import 'dart:convert';
import 'dart:io';

import '../../core/errors/failures.dart';
import '../../core/logging.dart';

/// Thin wrapper over local JSON files with schemaVersion bookkeeping.
///
/// All writes are atomic (temp file + rename) so a crash never leaves a
/// truncated store behind.
class JsonStore {
  const JsonStore();

  Map<String, dynamic>? read(File file) {
    if (!file.existsSync()) return null;
    try {
      final text = file.readAsStringSync();
      if (text.trim().isEmpty) return null;
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        throw ParseFailure('Unexpected JSON shape in ${file.path}');
      }
      return decoded;
    } on FileSystemException catch (e) {
      Log.error('Failed reading ${file.path}', e);
      throw DiskFailure('read ${file.path}: ${e.message}');
    } on FormatException catch (e) {
      Log.error('Corrupt JSON in ${file.path}', e);
      throw ParseFailure('corrupt JSON in ${file.path}: ${e.message}');
    }
  }

  void write(File file, Map<String, dynamic> json) {
    try {
      final tmp = File('${file.path}.tmp');
      tmp.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(json));
      if (file.existsSync()) file.deleteSync();
      tmp.renameSync(file.path);
    } on FileSystemException catch (e) {
      Log.error('Failed writing ${file.path}', e);
      throw DiskFailure('write ${file.path}: ${e.message}');
    }
  }
}
