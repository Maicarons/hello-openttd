import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/errors/failures.dart';
import '../../core/paths/app_paths.dart';
import '../../data/models/version_manifest.dart';
import 'cfg_document.dart';

/// Loads/saves `openttd.cfg` for a version with automatic timestamped
/// backups. Sensitive files (`private.cfg`) are never written here.
class CfgService {
  CfgService({required this.paths});

  final AppPaths paths;

  File configFileFor(VersionManifest version) {
    if (version.configMode == 'shared') {
      return paths.sharedConfigFile;
    }
    final dir = p.dirname(version.binaryPath);
    return File(p.join(dir, 'openttd.cfg'));
  }

  CfgDocument load(VersionManifest version) {
    final file = configFileFor(version);
    if (!file.existsSync()) return CfgDocument.empty();
    try {
      return CfgDocument.parse(file.readAsStringSync());
    } on FileSystemException catch (e) {
      throw DiskFailure('read cfg: ${e.message}');
    }
  }

  /// Saves [doc], keeping a timestamped `.bak-YYYYMMDDHHMMSS` copy first.
  /// Returns the backup path (or null for a first save).
  String? save(VersionManifest version, CfgDocument doc) {
    final file = configFileFor(version);
    String? backupPath;
    if (file.existsSync()) {
      String two(int n) => n.toString().padLeft(2, '0');
      final now = DateTime.now();
      final stamp =
          '${now.year}${two(now.month)}${two(now.day)}-${two(now.hour)}${two(now.minute)}${two(now.second)}';
      backupPath = '${file.path}.bak-$stamp';
      file.copySync(backupPath);
    }
    if (!file.parent.existsSync()) file.parent.createSync(recursive: true);
    file.writeAsStringSync(doc.serialize());
    _pruneBackups(file);
    return backupPath;
  }

  void _pruneBackups(File cfgFile) {
    final dir = cfgFile.parent;
    final backups = dir
        .listSync()
        .whereType<File>()
        .where((f) => p.basename(f.path).startsWith('${p.basename(cfgFile.path)}.bak-'))
        .toList()
      ..sort((a, b) => b.path.compareTo(a.path));
    for (final f in backups.skip(10)) {
      try {
        f.deleteSync();
      } on FileSystemException {
        // best effort
      }
    }
  }

  List<String> backups(VersionManifest version) {
    final file = configFileFor(version);
    if (!file.parent.existsSync()) return const [];
    return file.parent
        .listSync()
        .whereType<File>()
        .where((f) => p.basename(f.path).startsWith('${p.basename(file.path)}.bak-'))
        .map((f) => f.path)
        .toList()
      ..sort((b, a) => a.compareTo(b));
  }
}
