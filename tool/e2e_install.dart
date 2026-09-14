// End-to-end smoke test: installs official OpenTTD 15.3 (windows-x64) from the
// real CDN through the real service stack, then prints each phase.
// Run:  dart run tool/e2e_install.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hello_openttd/core/paths/app_paths.dart';
import 'package:hello_openttd/data/models/mirror_config.dart';
import 'package:hello_openttd/services/archive/archive_service.dart';
import 'package:hello_openttd/services/download/download_engine.dart';
import 'package:hello_openttd/services/mirror/mirror_service.dart';
import 'package:hello_openttd/services/security/url_validator.dart';
import 'package:hello_openttd/services/version_source/cdn_source.dart';
import 'package:hello_openttd/services/version_source/version_installer.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  final paths = await resolveAppPaths();
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'User-Agent': 'hello-openttd/e2e'},
  ));
  final mirrorService = MirrorService(
    mirrors: defaultMirrors(),
    dio: dio,
    urls: const UrlValidator(),
  );
  final engine = DownloadEngine(
    dio: dio,
    mirrorService: mirrorService,
    downloadDir: paths.downloadsDir,
  );
  final installer = VersionInstaller(
    paths: paths,
    engine: engine,
    archive: ArchiveService(),
  );

  stdout.writeln('data root: ${paths.dataRoot.path}');
  final source = CdnVersionSource(id: 'official', name: 'official', dio: dio);
  final releases = await source.listReleases();
  stdout.writeln('releases: ${releases.map((r) => r.version).join(', ')}');
  final release = releases.firstWhere(
    (r) => r.version == '15.3',
    orElse: () => throw StateError('15.3 not found'),
  );
  final asset = release.assets['windows-x64'];
  stdout.writeln('asset: ${asset?.url} sha256=${asset?.sha256?.substring(0, 8)}…');

  try {
    await for (final p in installer.install(
      release: release,
      platform: 'windows-x64',
      configMode: 'independent',
      versionId: 'official',
    )) {
      stdout.writeln(
          'phase=${p.phase} received=${p.received} total=${p.total} unverified=${p.unverified}');
    }
    stdout.writeln('INSTALL OK');
  } catch (e, st) {
    stdout.writeln('INSTALL FAILED: $e\n$st');
    exitCode = 1;
  }
  final installed = Directory(p.join(paths.versionsDir.path, 'official-15.3'));
  stdout.writeln('version dir exists: ${installed.existsSync()}');
  if (installed.existsSync()) {
    stdout.writeln(installed.listSync().map((f) => f.path).take(6).join('\n'));
  }
}
