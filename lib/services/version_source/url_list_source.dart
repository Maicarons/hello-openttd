import 'package:dio/dio.dart';

import '../../data/models/version_models.dart';
import 'version_source.dart';

/// User-hosted JSON release list (used for CMClient-style forks that do not
/// follow GitHub conventions, or any private build channel).
///
/// Schema: `[{"version": "1.2.3", "date": "2026-01-20", "prerelease": false,
///   "assets": {"windows-x64": {"url": "...", "size": 123, "sha256": "…"}}}]`
class UrlListVersionSource implements VersionSource {
  UrlListVersionSource({
    required this.id,
    required this.name,
    required this.listUrl,
    required Dio dio,
  }) : _dio = dio;

  @override
  final String id;
  @override
  final String name;
  final String listUrl;
  final Dio _dio;

  @override
  Future<List<SourceRelease>> listReleases() async {
    late Response<List<dynamic>> res;
    try {
      res = await _dio.get<List<dynamic>>(listUrl);
    } on DioException catch (e) {
      throwNetwork(e, 'fetch list $listUrl');
    }
    final releases = <SourceRelease>[];
    for (final item in res.data ?? const []) {
      if (item is! Map<String, dynamic>) continue;
      final version = item['version']?.toString();
      final assetsJson = item['assets'];
      if (version == null || assetsJson is! Map<String, dynamic>) continue;
      final assets = <String, SourceAsset>{};
      assetsJson.forEach((platform, a) {
        if (a is! Map<String, dynamic>) return;
        final url = a['url']?.toString();
        if (url == null || url.isEmpty) return;
        assets[platform] = SourceAsset(
          url: url,
          size: (a['size'] as num?)?.toInt(),
          sha256: a['sha256']?.toString(),
        );
      });
      if (assets.isEmpty) continue;
      releases.add(SourceRelease(
        version: version,
        sourceId: id,
        releasedAt: DateTime.tryParse((item['date'] ?? '').toString()),
        prerelease: ((item['prerelease'] as bool?) ?? false) || isPrereleaseVersion(version),
        assets: assets,
      ));
    }
    return releases;
  }
}
