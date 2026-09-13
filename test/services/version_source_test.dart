import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hello_openttd/services/version_source/cdn_source.dart';
import 'package:hello_openttd/services/version_source/github_source.dart';
import 'package:hello_openttd/services/version_source/url_list_source.dart';
import 'package:hello_openttd/services/version_source/version_source.dart';

void main() {
  group('platformKeyForFilename', () {
    test('maps distribution filenames to platform keys', () {
      expect(platformKeyForFilename('openttd-14.1-windows-win64.zip'), 'windows-x64');
      expect(platformKeyForFilename('openttd-14.1-windows-win32.zip'), 'windows-x86');
      expect(
          platformKeyForFilename('openttd-14.1-linux-generic-amd64.tar.xz'), 'linux-x64');
      expect(
          platformKeyForFilename('openttd-14.1-linux-generic-arm64.tar.xz'),
          'linux-arm64');
      expect(platformKeyForFilename('openttd-14.1-macos-universal.zip'), 'macos');
      expect(platformKeyForFilename('openttd-16.0-beta2-windows-win64.zip'), 'windows-x64');
      expect(platformKeyForFilename('source.tar.gz'), isNull);
    });
  });

  group('assetPreference', () {
    test('prefers zip over tar.xz over tar.gz', () {
      expect(assetPreference('a.zip'), lessThan(assetPreference('a.tar.xz')));
      expect(assetPreference('a.tar.xz'), lessThan(assetPreference('a.tar.gz')));
    });
  });

  group('CdnVersionSource parsing', () {
    test('parses latest.yaml + manifest.yaml into releases', () async {
      final dio = Dio();
      final latestYaml = '''
latest:
  - version: "15.3"
    name: OpenTTD 15.3
    category: stable
    date: "2026-06-01"
  - version: "16.0-beta2"
    name: OpenTTD 16.0-beta2
    category: testing
''';
      final manifestYaml = '''
name: OpenTTD
category: stable
version: 15.3
date: "2026-06-01"
files:
  - id: openttd-15.3-windows-win64.zip
    size: 50123456
    sha256sum: abc123
  - id: openttd-15.3-linux-generic-amd64.tar.xz
    size: 40123456
    sha256sum: def456
  - id: openttd-15.3-win64.exe
    size: 60123456
    sha256sum: 789aaa
''';
      dio.httpClientAdapter = _FakeAdapter({
        'https://cdn.openttd.org/openttd-releases/latest.yaml': latestYaml,
        'https://cdn.openttd.org/openttd-releases/15.3/manifest.yaml': manifestYaml,
        'https://cdn.openttd.org/openttd-releases/16.0-beta2/manifest.yaml': manifestYaml
            .replaceAll('15.3', '16.0-beta2'),
      });

      final source = CdnVersionSource(id: 'official', name: 'Official', dio: dio);
      final releases = await source.listReleases();

      expect(releases, isNotEmpty);
      final stable = releases.firstWhere((r) => r.version == '15.3');
      expect(stable.prerelease, isFalse);
      expect(stable.assets['windows-x64']!.url,
          'https://cdn.openttd.org/openttd-releases/15.3/openttd-15.3-windows-win64.zip');
      expect(stable.assets['windows-x64']!.sha256, 'abc123');
      expect(stable.assets['linux-x64']!.sha256, 'def456');
      final beta = releases.firstWhere((r) => r.version == '16.0-beta2');
      expect(beta.prerelease, isTrue);
    });
  });

  group('GithubVersionSource parsing', () {
    test('matches templates and keyword platforms, strips prefix', () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter({
        'https://api.github.com/repos/JGRennison/OpenTTD-patches/releases?per_page=100&page=1':
            [
          {
            'tag_name': 'jgrpp-0.61.2',
            'prerelease': false,
            'published_at': '2025-01-01T00:00:00Z',
            'assets': [
              {
                'name': 'openttd-0.61.2-windows-win64.zip',
                'size': 48000000,
                'browser_download_url':
                    'https://github.com/JGRennison/OpenTTD-patches/releases/download/jgrpp-0.61.2/openttd-0.61.2-windows-win64.zip',
              },
            ],
          },
        ],
      });

      final source = GithubVersionSource(
        id: 'jgrpp',
        name: 'JGRPP',
        repo: 'JGRennison/OpenTTD-patches',
        dio: dio,
        versionPrefix: 'jgrpp-',
      );
      final releases = await source.listReleases();
      expect(releases.single.version, '0.61.2');
      expect(releases.single.assets['windows-x64'], isNotNull);
    });
  });

  group('UrlListVersionSource parsing', () {
    test('reads explicit assets with enforced checksums', () async {
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter({
        'https://example.com/cmclient.json': [
          {
            'version': '1.2.3',
            'date': '2026-01-20',
            'assets': {
              'windows-x64': {
                'url': 'https://example.com/cmclient-1.2.3-win64.zip',
                'size': 123,
                'sha256': 'cafe',
              },
            },
          },
        ],
      });
      final source = UrlListVersionSource(
        id: 'cmclient',
        name: 'CMClient',
        listUrl: 'https://example.com/cmclient.json',
        dio: dio,
      );
      final releases = await source.listReleases();
      expect(releases.single.version, '1.2.3');
      expect(releases.single.assets['windows-x64']!.sha256, 'cafe');
    });
  });
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.routes);

  final Map<String, dynamic> routes;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final body = routes[options.uri.toString()];
    if (body == null) return ResponseBody.fromString('not found', 404);
    if (body is List) {
      return ResponseBody.fromString(
        jsonEncode(body),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    return ResponseBody.fromString(body as String, 200);
  }
}
