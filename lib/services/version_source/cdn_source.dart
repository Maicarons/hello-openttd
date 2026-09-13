import 'package:dio/dio.dart';
import 'package:yaml/yaml.dart';

import '../../core/errors/failures.dart';
import '../../data/models/version_models.dart';
import 'version_source.dart';

/// Official OpenTTD releases from the project CDN.
///
/// `{base}/latest.yaml` lists published versions; each version directory
/// carries a `manifest.yaml` whose `files` include size + sha256sum — so
/// official installs are checksum-verified end to end without trusting any
/// mirror (verified against openttd-manager-plus and cdn.openttd.org).
class CdnVersionSource implements VersionSource {
  CdnVersionSource({
    required this.id,
    required this.name,
    required Dio dio,
    this.baseUrl = 'https://cdn.openttd.org/openttd-releases',
  }) : _dio = dio;

  @override
  final String id;
  @override
  final String name;
  final String baseUrl;
  final Dio _dio;

  @override
  Future<List<SourceRelease>> listReleases() async {
    late Response<String> res;
    try {
      res = await _dio.get<String>('$baseUrl/latest.yaml');
    } on DioException catch (e) {
      throwNetwork(e, 'fetch latest.yaml');
    }
    if (res.data == null) throw ParseFailure('empty latest.yaml');

    late YamlList entries;
    try {
      final doc = loadYaml(res.data!);
      final latest = (doc as YamlMap)['latest'];
      if (latest is! YamlList) throw const FormatException('latest is not a list');
      entries = latest;
    } on YamlException catch (e) {
      throw ParseFailure('invalid latest.yaml: $e');
    } on FormatException catch (e) {
      throw ParseFailure('invalid latest.yaml: ${e.message}');
    }

    final releases = <SourceRelease>[];
    for (final entry in entries) {
      if (entry is! YamlMap) continue;
      final version = entry['version']?.toString();
      if (version == null || version.isEmpty) continue;
      final release = await _fetchRelease(version);
      if (release != null) releases.add(release);
    }
    return releases;
  }

  Future<SourceRelease?> _fetchRelease(String version) async {
    late Response<String> res;
    try {
      res = await _dio.get<String>('$baseUrl/$version/manifest.yaml');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throwNetwork(e, 'fetch manifest $version');
    }
    final text = res.data;
    if (text == null) return null;

    final YamlMap manifest;
    try {
      manifest = loadYaml(text) as YamlMap;
    } on YamlException catch (e) {
      throw ParseFailure('invalid manifest $version: $e');
    }

    final assets = <String, SourceAsset>{};
    final files = manifest['files'];
    if (files is YamlList) {
      for (final f in files) {
        if (f is! YamlMap) continue;
        final filename = f['id']?.toString();
        if (filename == null) continue;
        final platform = platformKeyForFilename(filename);
        if (platform == null) continue;
        putAsset(
          assets,
          platform,
          SourceAsset(
            url: '$baseUrl/$version/$filename',
            size: (f['size'] as num?)?.toInt(),
            sha256: f['sha256sum']?.toString(),
          ),
          filename,
        );
      }
    }
    final date = manifest['date']?.toString();
    return SourceRelease(
      version: version,
      sourceId: id,
      releasedAt: date == null ? null : DateTime.tryParse(date),
      prerelease: isPrereleaseVersion(version),
      assets: assets,
    );
  }
}
