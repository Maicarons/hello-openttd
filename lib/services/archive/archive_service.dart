import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart' as ar;
import 'package:path/path.dart' as p;

import '../../core/errors/failures.dart';
import '../../core/logging.dart';
import '../../core/paths/fs_guard.dart';

/// Archive extraction with zip-slip / link-escape protection and magic-byte
/// sanity checks (the "HTML page pretending to be a zip" failure mode).
class ArchiveService {
  ArchiveService({this.maxUncompressedBytes = 2 << 30, this.maxEntries = 50000});

  final int maxUncompressedBytes;
  final int maxEntries;
  final FsGuard _guard = const FsGuard();

  /// Extracts [archiveFile] into [targetDir] (created if missing).
  Future<void> extract(File archiveFile, Directory targetDir) async {
    if (!targetDir.existsSync()) targetDir.createSync(recursive: true);
    final name = archiveFile.path.toLowerCase();
    _verifyMagic(archiveFile, name);

    if (name.endsWith('.zip')) {
      await _extractZip(archiveFile, targetDir);
    } else if (name.endsWith('.tar.xz') || name.endsWith('.tar.gz') || name.endsWith('.tgz') || name.endsWith('.tar')) {
      await _extractWithSystemTar(archiveFile, targetDir, name);
    } else {
      throw ParseFailure('unsupported archive format: ${p.basename(name)}');
    }
  }

  void _verifyMagic(File file, String name) {
    final raf = file.openSync();
    try {
      final head = Uint8List(8);
      final n = raf.readIntoSync(head, 0, 8);
      final bytes = Uint8List.sublistView(head, 0, n);
      if (name.endsWith('.zip') &&
          !(n >= 4 && bytes[0] == 0x50 && bytes[1] == 0x4B)) {
        throw ParseFailure('not a zip archive (corrupted download?)');
      }
      if (name.endsWith('.tar.xz') &&
          !(n >= 6 && bytes[0] == 0xFD && bytes[1] == 0x37 && bytes[2] == 0x7A && bytes[3] == 0x58 && bytes[4] == 0x5A)) {
        throw ParseFailure('not an xz archive (corrupted download?)');
      }
      if ((name.endsWith('.tar.gz') || name.endsWith('.tgz')) &&
          !(n >= 2 && bytes[0] == 0x1F && bytes[1] == 0x8B)) {
        throw ParseFailure('not a gzip archive (corrupted download?)');
      }
    } finally {
      raf.closeSync();
    }
  }

  Future<void> _extractZip(File file, Directory targetDir) async {
    final Uint8List bytes;
    try {
      bytes = file.readAsBytesSync();
    } on FileSystemException catch (e) {
      throw DiskFailure('read archive: ${e.message}');
    }
    final ar.Archive archive;
    try {
      archive = ar.ZipDecoder().decodeBytes(bytes);
    } on ar.ArchiveException catch (e) {
      throw ParseFailure('invalid zip: $e');
    }

    var total = 0;
    var count = 0;
    for (final entry in archive) {
      if (++count > maxEntries) {
        throw ParseFailure('archive has too many entries (zip bomb?)');
      }
      final name = entry.name;
      if (_isUnsafeEntryName(name)) {
        throw PathGuardFailure('unsafe archive entry: "$name"');
      }
      if (entry.isFile) {
        total += entry.size;
        if (total > maxUncompressedBytes) {
          throw ParseFailure('archive too large when extracted (zip bomb?)');
        }
        final outPath = _guard.safeJoinAll(targetDir.path, name.split('/'));
        final outFile = File(outPath);
        if (!outFile.parent.existsSync()) {
          outFile.parent.createSync(recursive: true);
        }
        final data = entry.content as List<int>;
        outFile.writeAsBytesSync(data);
      }
    }
  }

  bool _isUnsafeEntryName(String name) {
    if (name.startsWith('/') || name.startsWith(r'\')) return true;
    if (name.contains('..')) return true;
    if (name.contains('\x00')) return true;
    if (RegExp(r'^[A-Za-z]:').hasMatch(name)) return true;
    return false;
  }

  Future<void> _extractWithSystemTar(File file, Directory targetDir, String name) async {
    if (Platform.isWindows) {
      // Windows tar (bsdtar) supports zip well but .tar.xz support depends on
      // the system liblzma; try it and surface a friendly error on failure.
      Log.debug('using system tar on windows for $name');
    }
    final result = await Process.run(
      'tar',
      ['-xf', file.path, '-C', targetDir.path, '--no-same-owner'],
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    if (result.exitCode != 0) {
      throw ParseFailure('tar exited ${result.exitCode}: ${result.stderr}');
    }
    // Post-verification: everything must be inside the target.
    await for (final entity in targetDir.list(recursive: true, followLinks: false)) {
      final link = entity is Link ? entity.target : null;
      if (link != null) {
        // Drop symlinks produced by crafted archives.
        await entity.delete();
        continue;
      }
      if (entity is! File && entity is! Directory) continue;
      if (!p.isWithin(targetDir.path, entity.path)) {
        throw PathGuardFailure('tar escaped target: ${entity.path}');
      }
    }
  }
}
