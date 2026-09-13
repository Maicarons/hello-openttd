import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart' as ar;
import 'package:path/path.dart' as p;

import '../../core/errors/failures.dart';
import '../../core/paths/app_paths.dart';
import '../../core/paths/fs_guard.dart';
import '../../data/models/version_manifest.dart';

class SaveEntry {
  SaveEntry({
    required this.file,
    required this.name,
    required this.size,
    required this.modified,
    required this.group,
  });

  final String file;
  final String name;
  final int size;
  final DateTime modified;

  /// `saves` | `autosave` | `scenarios` | `heightmaps`.
  final String group;
}

/// Savegame scanning, import/export, deletion and zip backup/restore
/// (docs/dev/saves).
class SaveService {
  SaveService({required this.paths});

  final AppPaths paths;
  final FsGuard _guard = const FsGuard();

  static const _saveSubdirs = {
    'saves': ['save'],
    'autosave': ['save', 'autosave'],
    'scenarios': ['scenario'],
    'heightmaps': ['heightmap'],
  };

  List<SaveEntry> scan(VersionManifest version) {
    final gameDir = p.dirname(version.binaryPath);
    final result = <SaveEntry>[];
    _saveSubdirs.forEach((group, components) {
      final dirPath = _guard.safeJoinAll(gameDir, components);
      final dir = Directory(dirPath);
      if (!dir.existsSync()) return;
      for (final entity in dir.listSync()) {
        if (entity is! File) continue;
        final ext = p.extension(entity.path).toLowerCase();
        final isSav = group == 'saves' || group == 'autosave' ? ext == '.sav' : false;
        final isScn = group == 'scenarios' && ext == '.scn';
        final isPng = group == 'heightmaps' && ext == '.png';
        if (!isSav && !isScn && !isPng) continue;
        final stat = entity.statSync();
        result.add(SaveEntry(
          file: entity.path,
          name: p.basenameWithoutExtension(entity.path),
          size: stat.size,
          modified: stat.modified,
          group: group,
        ));
      }
    });
    result.sort((a, b) => b.modified.compareTo(a.modified));
    return result;
  }

  /// Copies [sourceFile] into the version's save directory. Name collisions
  /// get a `-1`, `-2`… suffix. Returns the destination path.
  String import(VersionManifest version, String sourceFile) {
    final ext = p.extension(sourceFile).toLowerCase();
    if (ext != '.sav' && ext != '.scn') {
      throw ParseFailure('unsupported save file type: $ext');
    }
    final gameDir = p.dirname(version.binaryPath);
    final base = p.basename(sourceFile);
    final stem = p.basenameWithoutExtension(base);
    var candidate = _guard.safeJoinAll(gameDir, ['save', base]);
    var counter = 1;
    while (File(candidate).existsSync()) {
      candidate = _guard.safeJoinAll(gameDir, ['save', '$stem-$counter$ext']);
      counter++;
    }
    File(sourceFile).copySync(candidate);
    return candidate;
  }

  void export(SaveEntry entry, String targetDir) {
    final name = p.basename(entry.file);
    final target = p.join(targetDir, name);
    File(entry.file).copySync(target);
  }

  /// Moves to the launcher trash (`shared/.trash`), not a hard delete.
  void delete(SaveEntry entry) {
    final trash = Directory(p.join(paths.sharedDir.path, '.trash'));
    if (!trash.existsSync()) trash.createSync(recursive: true);
    final stamp = DateTime.now().millisecondsSinceEpoch;
    File(entry.file).renameSync(p.join(trash.path, '$stamp-${p.basename(entry.file)}'));
  }

  // ---------- backup / restore ----------

  /// Zips the version's save directory into `shared/backups` with a
  /// manifest.json inside. Returns the backup file.
  File backup(VersionManifest version) {
    final gameDir = p.dirname(version.binaryPath);
    final saveDir = Directory(_guard.safeJoinAll(gameDir, ['save']));
    String two(int n) => n.toString().padLeft(2, '0');
    final now = DateTime.now();
    final stamp =
        '${now.year}${two(now.month)}${two(now.day)}-${two(now.hour)}${two(now.minute)}${two(now.second)}';
    final outFile = File(p.join(paths.backupsDir.path, 'backup-$stamp.zip'));
    if (!outFile.parent.existsSync()) outFile.parent.createSync(recursive: true);

    final archive = ar.Archive();
    if (saveDir.existsSync()) {
      for (final entity in saveDir.listSync(recursive: true)) {
        if (entity is! File) continue;
        // Paths inside the zip are relative to the save directory itself.
        final rel = p.relative(entity.path, from: saveDir.path).replaceAll('\\', '/');
        final bytes = entity.readAsBytesSync();
        archive.addFile(ar.ArchiveFile('files/$rel', bytes.length, bytes));
      }
    }
    final manifestJson = jsonEncode({
      'createdAt': now.toIso8601String(),
      'versionId': version.id,
      'versionLabel': version.version,
      'files': archive.files.map((f) => f.name).toList(),
    });
    archive.addFile(
        ar.ArchiveFile.bytes('manifest.json', utf8.encode(manifestJson)));
    outFile.writeAsBytesSync(ar.ZipEncoder().encode(archive));
    _pruneBackups();
    return outFile;
  }

  void _pruneBackups() {
    final dir = paths.backupsDir;
    if (!dir.existsSync()) return;
    final zips = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.zip')).toList()
      ..sort((a, b) => b.path.compareTo(a.path));
    for (final f in zips.skip(20)) {
      try {
        f.deleteSync();
      } on FileSystemException {
        // best effort
      }
    }
  }

  List<File> backups() {
    final dir = paths.backupsDir;
    if (!dir.existsSync()) return const [];
    return dir.listSync().whereType<File>().where((f) => f.path.endsWith('.zip')).toList()
      ..sort((a, b) => b.path.compareTo(a.path));
  }

  /// Restores [backupFile] into the version's save directory, verifying the
  /// manifest and keeping a safety copy of overwritten files.
  void restore(VersionManifest version, File backupFile) {
    final bytes = backupFile.readAsBytesSync();
    final ar.Archive archive;
    try {
      archive = ar.ZipDecoder().decodeBytes(bytes);
    } on ar.ArchiveException catch (e) {
      throw ParseFailure('invalid backup zip: $e');
    }
    final manifestFile = archive.findFile('manifest.json');
    if (manifestFile == null) throw ParseFailure('backup has no manifest.json');

    final gameDir = p.dirname(version.binaryPath);
    final saveDirPath = _guard.safeJoinAll(gameDir, ['save']);
    for (final entry in archive) {
      if (!entry.isFile || entry.name == 'manifest.json') continue;
      if (!entry.name.startsWith('files/')) continue;
      final rel = entry.name.substring('files/'.length);
      if (rel.contains('..') || p.isAbsolute(rel)) {
        throw PathGuardFailure('unsafe backup entry: ${entry.name}');
      }
      final targetPath = p.join(saveDirPath, rel);
      if (!p.isWithin(p.normalize(saveDirPath), p.normalize(targetPath))) {
        throw PathGuardFailure('backup escapes save dir: ${entry.name}');
      }
      final target = File(targetPath);
      if (target.existsSync()) {
        final safe = File('$targetPath.restore-bak');
        target.copySync(safe.path);
      }
      if (!target.parent.existsSync()) target.parent.createSync(recursive: true);
      target.writeAsBytesSync(entry.content as List<int>);
    }
  }
}
