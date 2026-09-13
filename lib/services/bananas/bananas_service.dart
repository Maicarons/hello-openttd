import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../core/errors/failures.dart';
import '../../core/logging.dart';
import '../../core/paths/app_paths.dart';
import '../../core/paths/fs_guard.dart';

/// BaNaNaS online content (docs/dev/bananas).
///
/// The official HTTP API (`bananas-api.openttd.org/package/{type}`) exposes
/// metadata only — content itself is distributed in-game over the custom TCP
/// protocol and the CDN URLs are unguessable by design. So the launcher
/// offers browse/search/detail + web-jump + local import; in-game download
/// covers the bytes.
class BananasService {
  BananasService({required this.paths, required Dio dio})
      : _dio = dio;

  static const apiBase = 'https://bananas-api.openttd.org';
  static const webBase = 'https://bananas.openttd.org';

  final AppPaths paths;
  final Dio _dio;
  final FsGuard _guard = const FsGuard();

  /// BaNaNaS API content-type path → in-game target dir under content_download.
  static const types = <String, List<String>>{
    'newgrf': ['newgrf'],
    'ai': ['ai'],
    'game-script': ['game'],
    'base-music': ['baseset'],
  };

  Future<List<BananasPackage>> browse(String type, {bool forceRefresh = false}) async {
    final cacheFile = File(p.join(paths.bananasCacheDir.path, '$type.json'));
    if (!forceRefresh && cacheFile.existsSync()) {
      final age = DateTime.now().difference(cacheFile.statSync().modified);
      if (age < const Duration(hours: 6)) {
        try {
          final decoded = jsonDecode(cacheFile.readAsStringSync()) as Map<String, dynamic>;
          return (decoded['packages'] as List)
              .map((e) => BananasPackage.fromJson(e as Map<String, dynamic>))
              .toList();
        } on FormatException {
          // fall through to network
        }
      }
    }
    late Response<List<dynamic>> res;
    try {
      res = await _dio.get<List<dynamic>>('$apiBase/package/$type');
    } on DioException catch (e) {
      // Offline? fall back to a stale cache rather than failing hard.
      if (cacheFile.existsSync()) {
        try {
          final decoded = jsonDecode(cacheFile.readAsStringSync()) as Map<String, dynamic>;
          return (decoded['packages'] as List)
              .map((e) => BananasPackage.fromJson(e as Map<String, dynamic>))
              .toList();
        } on FormatException {
          // ignore
        }
      }
      throw NetworkFailure('BaNaNaS API: ${e.message}');
    }
    final packages = (res.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(BananasPackage.fromJson)
        .toList();
    try {
      if (!paths.bananasCacheDir.existsSync()) paths.bananasCacheDir.createSync(recursive: true);
      cacheFile.writeAsStringSync(jsonEncode({
        'fetchedAt': DateTime.now().toIso8601String(),
        'packages': packages.map((e) => e.toJson()).toList(),
      }));
    } on FileSystemException catch (e) {
      Log.error('bananas cache write failed', e);
    }
    return packages;
  }

  String webPageUrl(String type, String uniqueId) => '$webBase/package/$type/$uniqueId';

  // ---------- local content management ----------

  /// Files currently present under the version's content_download tree.
  List<InstalledContentFile> scanInstalled(String gameDir) {
    final root = _guard.safeJoinAll(gameDir, ['content_download']);
    final dir = Directory(root);
    if (!dir.existsSync()) return const [];
    final result = <InstalledContentFile>[];
    for (final entity in dir.listSync(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final rel = p.relative(entity.path, from: root).replaceAll('\\', '/');
      result.add(InstalledContentFile(
        relativePath: rel,
        size: entity.lengthSync(),
      ));
    }
    result.sort((a, b) => a.relativePath.compareTo(b.relativePath));
    return result;
  }

  /// Imports a local `.tar` package or bare `.grf` into the matching
  /// content_download subdirectory.
  String importLocal(String gameDir, String sourceFile) {
    final name = p.basename(sourceFile);
    final lower = name.toLowerCase();
    final List<String> targetDir;
    if (lower.endsWith('.grf')) {
      targetDir = ['content_download', 'newgrf'];
    } else if (lower.endsWith('.tar') || lower.endsWith('.tar.gz')) {
      targetDir = ['content_download', 'newgrf'];
    } else {
      throw ParseFailure('unsupported content file: $name');
    }
    final destPath = _guard.safeJoinAll(gameDir, [...targetDir, name]);
    final dest = File(destPath);
    if (!dest.parent.existsSync()) dest.parent.createSync(recursive: true);
    File(sourceFile).copySync(dest.path);
    return dest.path;
  }

  void deleteInstalled(String gameDir, String relativePath) {
    final filePath = _guard.safeJoinAll(gameDir, ['content_download', ...relativePath.split('/')]);
    final file = File(filePath);
    if (file.existsSync()) file.deleteSync();
  }
}

class BananasPackage {
  BananasPackage({
    required this.id,
    required this.name,
    this.description = '',
    this.authors = const [],
    this.latestVersion,
    this.latestFilesize,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final List<String> authors;
  final String? latestVersion;
  final int? latestFilesize;
  final DateTime? updatedAt;

  factory BananasPackage.fromJson(Map<String, dynamic> json) {
    final versions = json['versions'] as List? ?? const [];
    Map<String, dynamic>? latest;
    DateTime? latestDate;
    for (final v in versions) {
      if (v is! Map<String, dynamic>) continue;
      final date = DateTime.tryParse((v['upload-date'] ?? '').toString());
      if (latest == null || (date != null && (latestDate == null || date.isAfter(latestDate)))) {
        latest = v;
        latestDate = date;
      }
    }
    return BananasPackage(
      id: (json['unique-id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      authors: ((json['authors'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((a) => (a['display-name'] ?? '').toString())
          .where((s) => s.isNotEmpty)
          .toList(),
      latestVersion: latest?['version']?.toString(),
      latestFilesize: (latest?['filesize'] as num?)?.toInt(),
      updatedAt: latestDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'unique-id': id,
        'name': name,
        'description': description,
        'authors': authors.map((a) => {'display-name': a}).toList(),
        'versions': [
          {
            'version': latestVersion,
            'filesize': latestFilesize,
            'upload-date': updatedAt?.toIso8601String(),
          }
        ],
      };
}

class InstalledContentFile {
  InstalledContentFile({required this.relativePath, required this.size});
  final String relativePath;
  final int size;
}
