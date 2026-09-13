import 'package:dio/dio.dart';

import '../../core/errors/failures.dart';
import '../../data/repositories/json_store.dart';
import 'cdn_source.dart';
import 'github_source.dart';
import 'url_list_source.dart';
import 'version_source.dart';

/// User-defined custom source (persisted in settings store `sources` list).
class CustomSourceConfig {
  CustomSourceConfig({
    required this.id,
    required this.name,
    required this.kind,
    this.repo = '',
    this.listUrl = '',
    this.versionPrefix = '',
    this.enabled = true,
  });

  final String id;
  final String name;

  /// `github` or `url-list`.
  final String kind;
  final String repo;
  final String listUrl;
  final String versionPrefix;
  final bool enabled;

  factory CustomSourceConfig.fromJson(Map<String, dynamic> json) => CustomSourceConfig(
        id: json['id'] as String,
        name: json['name'] as String,
        kind: json['kind'] as String,
        repo: (json['repo'] as String?) ?? '',
        listUrl: (json['listUrl'] as String?) ?? '',
        versionPrefix: (json['versionPrefix'] as String?) ?? '',
        enabled: (json['enabled'] as bool?) ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'kind': kind,
        'repo': repo,
        'listUrl': listUrl,
        'versionPrefix': versionPrefix,
        'enabled': enabled,
      };
}

/// Builds the full source list: built-ins + enabled custom sources.
class SourceRegistry {
  SourceRegistry({required Dio dio, this.store = const JsonStore(), List<CustomSourceConfig> custom = const []})
      : _dio = dio,
        _custom = custom;

  static const officialId = 'official';
  static const jgrppId = 'jgrpp';
  static const cmclientId = 'cmclient';

  final Dio _dio;
  final JsonStore store;
  final List<CustomSourceConfig> _custom;

  List<VersionSource> all() {
    return [
      CdnVersionSource(id: officialId, name: 'OpenTTD official (CDN)', dio: _dio),
      GithubVersionSource(
          id: jgrppId, name: 'JGRPP', repo: 'JGRennison/OpenTTD-patches', dio: _dio),
      GithubVersionSource(
          id: cmclientId, name: 'CMClient (CityMania)', repo: 'citymania-org/cmclient', dio: _dio),
      ..._custom.where((c) => c.enabled).map(_buildCustom),
    ];
  }

  VersionSource _buildCustom(CustomSourceConfig c) {
    switch (c.kind) {
      case 'github':
        return GithubVersionSource(
          id: c.id,
          name: c.name,
          repo: c.repo,
          dio: _dio,
          versionPrefix: c.versionPrefix,
        );
      case 'url-list':
        return UrlListVersionSource(id: c.id, name: c.name, listUrl: c.listUrl, dio: _dio);
      default:
        throw ParseFailure('Unknown custom source kind: ${c.kind}');
    }
  }

  VersionSource? byId(String id) {
    for (final s in all()) {
      if (s.id == id) return s;
    }
    return null;
  }
}
