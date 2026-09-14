import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/errors/failures.dart';
import '../../core/logging.dart';
import '../../core/paths/app_paths.dart';
import '../../core/paths/fs_guard.dart';
import '../../data/models/version_manifest.dart';
import '../../data/models/version_models.dart';
import '../archive/archive_service.dart';
import '../download/download_engine.dart';

enum InstallPhase { downloading, verifying, extracting, finishing }

class InstallProgress {
  InstallProgress({required this.phase, this.received, this.total, this.speedBps, this.unverified = false});
  final InstallPhase phase;
  final int? received;
  final int? total;
  final double? speedBps;
  final bool unverified;
}

/// Orchestrates version installation: download (mirror chain) → checksum →
/// extract (guarded) → write manifest. Failures never leave a half-install.
class VersionInstaller {
  VersionInstaller({
    required this.paths,
    required this.engine,
    required this.archive,
  });

  final AppPaths paths;
  final DownloadEngine engine;
  final ArchiveService archive;
  final FsGuard _guard = const FsGuard();

  Stream<InstallProgress> install({
    required SourceRelease release,
    required String platform,
    required String configMode,
    required String versionId,
  }) {
    final controller = StreamController<InstallProgress>();
    _runInstall(
      controller,
      release: release,
      platform: platform,
      configMode: configMode,
      versionId: versionId,
    );
    return controller.stream;
  }

  Future<void> _runInstall(
    StreamController<InstallProgress> controller, {
    required SourceRelease release,
    required String platform,
    required String configMode,
    required String versionId,
  }) async {
    try {
      final asset = release.assets[platform] ??
          (throw NotFoundFailure('release ${release.version} has no $platform asset'));

      final dirName = '$versionId-${release.version}';
      final targetDir = Directory(_guard.safeJoin(paths.versionsDir.path, dirName));
      if (targetDir.existsSync()) {
        throw ConflictFailure('version directory already exists: ${targetDir.path}');
      }

      controller.add(InstallProgress(phase: InstallPhase.downloading));
      final fileName = asset.url.split('/').last.split('?').first;
      DownloadResult result;
      try {
        // Forward real byte progress from the engine so the install dialog
        // shows an advancing bar instead of an indeterminate spinner.
        engine.onProgress = (received, total, bps) {
          controller.add(InstallProgress(
            phase: InstallPhase.downloading,
            received: received,
            total: total,
            speedBps: bps,
          ));
        };
        result = await engine.downloadFile(
          url: asset.url,
          fileName: fileName,
          expectedSha256: asset.sha256,
          expectedSize: asset.size,
        );
      } on Failure {
        rethrow;
      } finally {
        engine.onProgress = null;
      }
      final verified = asset.sha256 != null;
      controller.add(InstallProgress(phase: InstallPhase.verifying, unverified: !verified));

      controller.add(InstallProgress(phase: InstallPhase.extracting));
      final tmpDir = Directory(p.join(paths.versionsDir.path, '.$dirName.tmp'));
      if (tmpDir.existsSync()) tmpDir.deleteSync(recursive: true);
      tmpDir.createSync(recursive: true);
      try {
        await archive.extract(result.file, tmpDir);
        _locateBinary(tmpDir); // fail fast before moving into place
        if (targetDir.existsSync()) {
          throw ConflictFailure('version directory appeared during install');
        }
        tmpDir.renameSync(targetDir.path);
      } on Failure {
        if (tmpDir.existsSync()) {
          try {
            tmpDir.deleteSync(recursive: true);
          } on FileSystemException catch (e) {
            Log.error('cleanup of $tmpDir failed', e);
          }
        }
        rethrow;
      } finally {
        try {
          if (result.file.existsSync()) result.file.deleteSync();
        } on FileSystemException {
          // keep the cache file on failure to delete; harmless
        }
      }

    final binary = _locateBinary(targetDir);
    final manifest = VersionManifest(
      id: versionId,
      sourceId: release.sourceId,
      version: release.version,
      platform: platform,
      installedAt: DateTime.now(),
      binaryPath: binary.path,
      sha256: result.sha256,
      verified: verified,
      configMode: configMode,
    );
    File(p.join(targetDir.path, 'manifest.json'))
        .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(manifest.toJson()));
    controller.add(InstallProgress(phase: InstallPhase.finishing, unverified: !verified));
    } catch (e, st) {
      controller.addError(e, st);
    } finally {
      await controller.close();
    }
  }

  /// Finds the game executable inside an installed/extracted directory.
  File _locateBinary(Directory dir) {
    final exeNames = Platform.isWindows
        ? ['openttd.exe']
        : Platform.isMacOS
            ? ['openttd']
            : ['openttd'];
    for (final name in exeNames) {
      final direct = File(p.join(dir.path, name));
      if (direct.existsSync()) {
        if (!Platform.isWindows) {
          try {
            Process.runSync('chmod', ['+x', direct.path]);
          } catch (_) {}
        }
        return direct;
      }
    }
    // One level of nesting (some archives wrap everything in a folder).
    for (final child in dir.listSync()) {
      if (child is Directory) {
        for (final name in exeNames) {
          final nested = File(p.join(child.path, name));
          if (nested.existsSync()) {
            if (!Platform.isWindows) {
              try {
                Process.runSync('chmod', ['+x', nested.path]);
              } catch (_) {}
            }
            return nested;
          }
        }
      }
    }
    throw NotFoundFailure('no openttd executable found in ${dir.path}');
  }
}
