import 'package:dio/dio.dart';

import '../../data/models/version_models.dart';
import 'version_source.dart';

/// Releases fetched from a GitHub repository (JGRPP, CMClient, custom forks).
///
/// Assets are matched to platforms by keyword; optional per-platform
/// templates (`{version}` placeholder) take precedence when provided.
class GithubVersionSource implements VersionSource {
  GithubVersionSource({
    required this.id,
    required this.name,
    required this.repo,
    required Dio dio,
    this.token = '',
    this.versionPrefix = '',
    this.templates = const {},
  }) : _dio = dio;

  @override
  final String id;
  @override
  final String name;
  final String repo;
  final String token;
  final String versionPrefix;

  /// platform key → filename template, e.g.
  /// `{'windows-x64': 'openttd-{version}-windows-win64.zip'}`.
  final Map<String, String> templates;

  final Dio _dio;
  static const _perPage = 100;

  @override
  Future<List<SourceRelease>> listReleases() async {
    final releases = <SourceRelease>[];
    for (var page = 1; page <= 3; page++) {
      late Response<List<dynamic>> res;
      try {
        res = await _dio.get<List<dynamic>>(
          'https://api.github.com/repos/$repo/releases',
          queryParameters: {'per_page': '$_perPage', 'page': '$page'},
          options: Options(headers: _headers()),
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 403 && releases.isNotEmpty) break;
        throwNetwork(e, 'fetch releases $repo');
      }
      final items = res.data ?? const [];
      if (items.isEmpty) break;
      for (final item in items) {
        if (item is! Map<String, dynamic>) continue;
        final release = _parseRelease(item);
        if (release != null) releases.add(release);
      }
      if (items.length < _perPage) break;
    }
    return releases;
  }

  Map<String, String> _headers() => {
        'Accept': 'application/vnd.github+json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  SourceRelease? _parseRelease(Map<String, dynamic> json) {
    var version = (json['tag_name'] as String?) ?? '';
    if (version.isEmpty) return null;
    if (versionPrefix.isNotEmpty && version.startsWith(versionPrefix)) {
      version = version.substring(versionPrefix.length);
    }
    if (version.isEmpty) return null;

    final assets = <String, SourceAsset>{};
    final list = json['assets'] as List? ?? const [];
    for (final a in list) {
      if (a is! Map<String, dynamic>) continue;
      final filename = (a['name'] as String?) ?? '';
      final url = a['browser_download_url'] as String?;
      if (filename.isEmpty || url == null) continue;
      for (final entry in templates.entries) {
        final expected = entry.value.replaceAll('{version}', version);
        if (filename == expected) {
          assets[entry.key] = SourceAsset(url: url, size: (a['size'] as num?)?.toInt());
          break;
        }
      }
      final platform = assets.isEmpty ? platformKeyForFilename(filename) : null;
      if (platform != null) {
        putAsset(assets, platform, SourceAsset(url: url, size: (a['size'] as num?)?.toInt()), filename);
      }
    }
    if (assets.isEmpty) return null;

    return SourceRelease(
      version: version,
      sourceId: id,
      releasedAt: DateTime.tryParse((json['published_at'] as String?) ?? ''),
      prerelease: ((json['prerelease'] as bool?) ?? false) || isPrereleaseVersion(version),
      assets: assets,
    );
  }
}
