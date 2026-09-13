import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hello_openttd/core/errors/failures.dart';
import 'package:hello_openttd/data/models/mirror_config.dart';
import 'package:hello_openttd/services/download/download_engine.dart';
import 'package:hello_openttd/services/mirror/mirror_service.dart';
import 'package:hello_openttd/services/security/url_validator.dart';

/// Local HTTP server fixture with real Range/206 semantics.
class _TestServer {
  _TestServer(this.payload);

  final Uint8List payload;
  late HttpServer server;
  int requests = 0;

  String get url => 'http://127.0.0.1:${server.port}/file.bin';

  Future<void> start() async {
    server = await HttpServer.bind('127.0.0.1', 0);
    server.listen((request) async {
      requests++;
      final range = request.headers.value('range');
      if (range == null) {
        request.response.statusCode = 200;
        request.response.contentLength = payload.length;
        request.response.add(payload);
        await request.response.close();
        return;
      }
      final match = RegExp(r'bytes=(\d+)-').firstMatch(range);
      final start = int.parse(match!.group(1)!);
      request.response.statusCode = 206;
      request.response.headers.set(
        'content-range',
        'bytes $start-${payload.length - 1}/${payload.length}',
      );
      request.response.contentLength = payload.length - start;
      request.response.add(payload.sublist(start));
      await request.response.close();
    });
  }

  Future<void> stop() => server.close(force: true);
}

DownloadEngine engine(Directory dir, List<MirrorConfig> mirrors) => DownloadEngine(
      dio: Dio(),
      mirrorService: MirrorService(
        mirrors: mirrors,
        dio: Dio(),
        urls: const UrlValidator(allowLoopbackHttp: true),
      ),
      downloadDir: dir,
    );

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hello-openttd-dl');
  });

  tearDown(() async {
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  Future<List<MirrorConfig>> directOnly() async => [defaultMirrors().first];

  test('downloads a file and reports progress', () async {
    final payload = Uint8List.fromList(utf8.encode('hello openttd' * 100));
    final server = _TestServer(payload);
    await server.start();
    addTearDown(server.stop);

    final e = engine(tempDir, await directOnly());
    var progressCalls = 0;
    e.onProgress = (_, __, ___) => progressCalls++;

    final result = await e.downloadFile(
      url: server.url,
      fileName: 'file.bin',
      mirrorStrategy: 'official',
    );

    expect(result.file.readAsStringSync(), utf8.decode(payload));
    expect(result.sha256, sha256.convert(payload).toString());
    expect(progressCalls, greaterThan(0));
    expect(File(result.file.path).existsSync(), isTrue);
  });

  test('verifies sha256 and fails closed on mismatch', () async {
    final payload = Uint8List.fromList(utf8.encode('legit content'));
    final server = _TestServer(payload);
    await server.start();
    addTearDown(server.stop);

    final e = engine(tempDir, await directOnly());
    await expectLater(
      e.downloadFile(
        url: server.url,
        fileName: 'file.bin',
        expectedSha256: 'deadbeef',
        mirrorStrategy: 'official',
      ),
      throwsA(isA<ChecksumFailure>()),
    );
    // No target file left behind.
    expect(File('${tempDir.path}/file.bin').existsSync(), isFalse);
  });

  test('resumes from an interrupted download via Range', () async {
    final payload = Uint8List.fromList(utf8.encode('A' * 1000 + 'B' * 1000));
    final server = _TestServer(payload);
    await server.start();
    addTearDown(server.stop);

    final e = engine(tempDir, await directOnly());
    // Simulate a previous partial download of 1000 bytes.
    final taskId = sha256.convert(utf8.encode(server.url)).toString().substring(0, 16);
    File('${tempDir.path}/$taskId.part').writeAsBytesSync(payload.sublist(0, 1000));
    File('${tempDir.path}/$taskId.meta.json').writeAsStringSync(
      jsonEncode({'url': server.url, 'receivedBytes': 1000}),
    );

    final result = await e.downloadFile(
      url: server.url,
      fileName: 'file.bin',
      mirrorStrategy: 'official',
    );

    expect(result.file.lengthSync(), 2000);
    expect(result.file.readAsBytesSync(), payload);
    expect(server.requests, 1); // single request carrying Range
  });

  test('falls back to the next mirror when one fails', () async {
    final payload = Uint8List.fromList(utf8.encode('fallback ok'));
    final server = _TestServer(payload);
    await server.start();
    addTearDown(server.stop);

    final e = engine(tempDir, [
      MirrorConfig(id: 'dead', name: 'dead', template: 'https://dead.invalid/{url}'),
      defaultMirrors().first,
    ]);
    final result = await e.downloadFile(
      url: server.url,
      fileName: 'file.bin',
      mirrorStrategy: 'auto', // probing will mark dead.invalid unreachable
    );
    expect(result.file.readAsStringSync(), 'fallback ok');
  });
}
