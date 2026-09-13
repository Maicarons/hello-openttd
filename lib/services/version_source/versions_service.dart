import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/errors/failures.dart';
import '../../core/paths/app_paths.dart';
import '../../core/paths/fs_guard.dart';
import '../../data/models/version_manifest.dart';

/// Lists, adopts and removes installed versions.
class VersionsService {
  VersionsService({required this.paths});

  final AppPaths paths;
  final FsGuard _guard = const FsGuard();

  List<VersionManifest> installed() {
    final dir = paths.versionsDir;
    if (!dir.existsSync()) return [];
    final result = <VersionManifest>[];
    for (final child in dir.listSync()) {
      if (child is! Directory) continue;
      final manifestFile = File(p.join(child.path, 'manifest.json'));
      if (!manifestFile.existsSync()) continue;
      try {
        final json = jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
        final manifest = VersionManifest.fromJson(json);
        // Manifest must agree with reality; treat moved/renamed dirs as absent.
        if (File(manifest.binaryPath).existsSync()) result.add(manifest);
      } on FormatException {
        // skip corrupt manifests
      }
    }
    result.sort((a, b) => b.installedAt.compareTo(a.installedAt));
    return result;
  }

  VersionManifest? byId(String id) {
    for (final v in installed()) {
      if (v.id == id) return v;
    }
    return null;
  }

  /// Registers an existing (manually installed) game directory without
  /// moving or copying anything.
  VersionManifest adoptLocal({required String directory, required String versionLabel}) {
    final dir = Directory(directory);
    if (!dir.existsSync()) throw NotFoundFailure('directory not found: $directory');
    final exeNames = Platform.isWindows ? 'openttd.exe' : 'openttd';
    final binary = File(p.join(dir.path, exeNames));
    if (!binary.existsSync()) {
      throw NotFoundFailure('no openttd executable in $directory');
    }
    final id = _guard.safeJoin(paths.versionsDir.path, '.').isEmpty
        ? 'local-${DateTime.now().millisecondsSinceEpoch}'
        : 'local-${DateTime.now().millisecondsSinceEpoch}';
    final manifest = VersionManifest(
      id: id,
      sourceId: 'local',
      version: versionLabel,
      platform: Platform.operatingSystem,
      installedAt: DateTime.now(),
      binaryPath: binary.path,
    );
    File(p.join(dir.path, 'manifest.json')).writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(manifest.toJson()),
    );
    return manifest;
  }

  void uninstall(String id, {required bool deleteData}) {
    final manifest = byId(id) ?? (throw NotFoundFailure('version not installed: $id'));
    final dir = Directory(p.dirname(manifest.binaryPath));
    if (deleteData && dir.existsSync()) {
      dir.deleteSync(recursive: true);
    } else {
      final manifestFile = File(p.join(dir.path, 'manifest.json'));
      if (manifestFile.existsSync()) manifestFile.deleteSync();
    }
  }

  void updateLaunchStats(VersionManifest manifest) {
    manifest.launchCount += 1;
    manifest.lastLaunchedAt = DateTime.now();
    final dir = Directory(p.dirname(manifest.binaryPath));
    final manifestFile = File(p.join(dir.path, 'manifest.json'));
    if (manifestFile.existsSync()) {
      manifestFile.writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(manifest.toJson()),
      );
    }
  }
}
