import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../core/errors/failures.dart';
import '../../core/logging.dart';
import '../mirror/mirror_service.dart';

/// Streaming download with HTTP Range resume, per-mirror fallback and
/// streamed SHA-256 verification (docs/dev/download-engine).
class DownloadEngine {
  DownloadEngine({
    required this.dio,
    required this.mirrorService,
    required this.downloadDir,
    this.connectTimeout = const Duration(seconds: 15),
    this.maxRetriesPerMirror = 3,
  });

  final Dio dio;
  final MirrorService mirrorService;
  final Directory downloadDir;
  final Duration connectTimeout;
  final int maxRetriesPerMirror;

  /// Progress events (received bytes, total, speed).
  void Function(int received, int? total, double bps)? onProgress;

  DownloadHandle? _active;

  /// Cancels the current download, if any.
  void cancel() => _active?.cancel();

  /// Downloads [url] into [downloadDir]/[fileName] via the mirror chain.
  ///
  /// Returns the downloaded file. When [expectedSha256] is given the result
  /// is verified (fail-closed); otherwise the computed hash is returned in
  /// the [DownloadResult] and the caller decides how to label trust.
  Future<DownloadResult> downloadFile({
    required String url,
    required String fileName,
    String? expectedSha256,
    int? expectedSize,
    String mirrorStrategy = 'auto',
    String? fixedMirrorId,
  }) async {
    final handle = DownloadHandle();
    _active = handle;
    try {
      final probed = mirrorStrategy == 'auto' || mirrorStrategy == 'fastest'
          ? await mirrorService.probeAll()
          : null;
      final chain = mirrorService.orderForDownload(
        strategy: mirrorStrategy,
        fixedId: fixedMirrorId,
        probed: probed,
      );
      if (chain.isEmpty) throw NetworkFailure('no download source available');

      Object? lastError;
      for (final mirror in chain) {
        try {
          final mirrorUrl = mirrorService.translate(url, mirror);
          return await _downloadFrom(
            handle: handle,
            url: mirrorUrl,
            fileName: fileName,
            expectedSha256: expectedSha256,
            expectedSize: expectedSize,
          );
        } on CancelledFailure {
          rethrow;
        } on Failure catch (e) {
          Log.info('mirror ${mirror.name} failed: ${e.detail}');
          lastError = e;
        }
      }
      if (lastError is Failure) throw lastError;
      throw NetworkFailure('all mirrors failed for $url');
    } finally {
      if (identical(_active, handle)) _active = null;
    }
  }

  Future<DownloadResult> _downloadFrom({
    required DownloadHandle handle,
    required String url,
    required String fileName,
    required String? expectedSha256,
    required int? expectedSize,
  }) async {
    final taskId = sha256.convert(utf8.encode(url)).toString().substring(0, 16);
    final partFile = File(p.join(downloadDir.path, '$taskId.part'));
    final metaFile = File(p.join(downloadDir.path, '$taskId.meta.json'));

    var received = 0;
    String? remoteEtag;
    if (metaFile.existsSync() && partFile.existsSync()) {
      try {
        final meta = jsonDecode(metaFile.readAsStringSync()) as Map<String, dynamic>;
        if (meta['url'] == url && (meta['totalBytes'] == expectedSize || expectedSize == null)) {
          received = (meta['receivedBytes'] as num).toInt();
          remoteEtag = meta['etag'] as String?;
        }
      } on FormatException {
        // stale meta — restart
      }
    }
    if (received > 0 && !partFile.existsSync()) received = 0;
    if (partFile.existsSync() && partFile.lengthSync() != received) {
      received = 0;
    }

    var attempt = 0;
    while (true) {
      attempt++;
      try {
        final sw = Stopwatch()..start();
        final headers = <String, String>{
          if (received > 0) 'Range': 'bytes=$received-',
        };
        final response = await dio.get<ResponseBody>(
          url,
          options: Options(
            responseType: ResponseType.stream,
            headers: headers,
            connectTimeout: const Duration(seconds: 8),
            followRedirects: true,
            maxRedirects: 5,
            validateStatus: (s) => s != null && s < 400,
          ),
        );

        final status = response.statusCode ?? 0;
        final totalHeader = _contentLength(response.headers);
        final isResumed = status == 206;
        if (received > 0 && !isResumed) {
          // Server ignored Range — restart from zero.
          received = 0;
        }
        final total = switch ((status, totalHeader)) {
          (200, final t?) => t,
          (206, final t?) => t + received,
          (_, final t?) => t,
          (_, null) => expectedSize,
        };
        if (expectedSize != null && total != null && total != expectedSize) {
          throw ParseFailure('size mismatch: header $total expected $expectedSize');
        }
        remoteEtag = response.headers.value('etag') ?? remoteEtag;

        final sink = partFile.openSync(mode: received > 0 ? FileMode.append : FileMode.write);
        final digestSink = _DigestSink();
        final hasher = sha256.startChunkedConversion(digestSink);
        if (received > 0) {
          // Hash the already-downloaded prefix so verification covers the
          // whole file, not just the resumed tail.
          await for (final chunk in partFile.openRead(0, received)) {
            hasher.add(chunk);
          }
        }
        var lastMetaWrite = 0;
        try {
          await for (final chunk in response.data!.stream) {
            if (handle.cancelled) {
              throw CancelledFailure();
            }
            sink.writeFromSync(chunk);
            hasher.add(chunk);
            received += chunk.length;
            final bps = received / (sw.elapsedMicroseconds / 1e6);
            onProgress?.call(received, total, bps);
            if (DateTime.now().millisecondsSinceEpoch - lastMetaWrite > 800) {
              _writeMeta(metaFile, url, total, received, remoteEtag);
              lastMetaWrite = DateTime.now().millisecondsSinceEpoch;
            }
          }
        } finally {
          sink.flushSync();
          sink.closeSync();
        }

        if (total != null && received != total) {
          throw NetworkFailure('connection closed early ($received/$total)');
        }

        hasher.close();
        final digest = digestSink.digest.toString();
        if (expectedSha256 != null && digest != expectedSha256) {
          partFile.deleteSync();
          _deleteMeta(metaFile);
          throw ChecksumFailure(expected: expectedSha256, actual: digest);
        }

        final target = File(p.join(downloadDir.path, fileName));
        if (target.existsSync()) target.deleteSync();
        partFile.renameSync(target.path);
        _deleteMeta(metaFile);
        return DownloadResult(file: target, sha256: digest, resumedBytes: 0);
      } on CancelledFailure {
        rethrow;
      } on DioException catch (e) {
        if (handle.cancelled) throw CancelledFailure();
        if (attempt >= maxRetriesPerMirror) {
          throw NetworkFailure('download failed after $attempt attempts: ${e.message}');
        }
        await Future<void>.delayed(Duration(milliseconds: 500 * (1 << (attempt - 1))));
      } on SocketException catch (e) {
        if (attempt >= maxRetriesPerMirror) {
          throw NetworkFailure('network error: ${e.message}');
        }
        await Future<void>.delayed(Duration(milliseconds: 500 * (1 << (attempt - 1))));
      }
    }
  }

  int? _contentLength(Headers headers) {
    final raw = headers.value('content-length');
    if (raw == null) return null;
    return int.tryParse(raw);
  }

  void _writeMeta(File meta, String url, int? total, int received, String? etag) {
    try {
      meta.writeAsStringSync(jsonEncode({
        'url': url,
        'totalBytes': total,
        'receivedBytes': received,
        'etag': etag,
        'updatedAt': DateTime.now().toIso8601String(),
      }));
    } on FileSystemException {
      // best effort
    }
  }

  void _deleteMeta(File meta) {
    try {
      if (meta.existsSync()) meta.deleteSync();
    } on FileSystemException {
      // best effort
    }
  }
}

class DownloadResult {
  DownloadResult({required this.file, required this.sha256, required this.resumedBytes});

  final File file;

  /// SHA-256 of the complete file as downloaded.
  final String sha256;
  final int resumedBytes;
}

/// Collects the [Digest] emitted when a chunked hash conversion closes.
class _DigestSink implements Sink<Digest> {
  Digest? digest;

  @override
  void add(Digest data) => digest = data;

  @override
  void close() {}
}

/// Cooperative cancellation token for downloads.
class DownloadHandle {
  bool cancelled = false;
  void cancel() => cancelled = true;
}
