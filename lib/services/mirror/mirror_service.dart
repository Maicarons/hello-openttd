import 'package:dio/dio.dart';

import '../../core/errors/failures.dart';
import '../../data/models/mirror_config.dart';
import '../security/url_validator.dart';

/// Chooses and applies download mirrors.
///
/// Mirrors are prefix/rewrite templates; file downloads only — API endpoints
/// (GitHub, CDN manifests, BaNaNaS) always go direct.
class MirrorService {
  MirrorService({required this.mirrors, required Dio dio, UrlValidator? urls})
      : _dio = dio,
        _urls = urls ?? const UrlValidator();

  List<MirrorConfig> mirrors;
  final Dio _dio;
  final UrlValidator _urls;

  List<MirrorConfig> candidates() {
    final list = mirrors.where((m) => m.enabled).toList()
      ..sort((a, b) => a.weight.compareTo(b.weight));
    // The direct source is always the last-resort fallback.
    final direct = list.where((m) => m.id == builtinDirectMirrorId).toList();
    final others = list.where((m) => m.id != builtinDirectMirrorId).toList();
    return [...others, ...direct];
  }

  /// Applies the mirror template to an original URL.
  String translate(String originalUrl, MirrorConfig mirror) {
    if (mirror.id == builtinDirectMirrorId) return originalUrl;
    var template = mirror.template;
    if (template.contains('{url}')) {
      final out = template.replaceAll('{url}', originalUrl);
      return _urls.validate(out).toString();
    }
    final uri = Uri.parse(originalUrl);
    // https://github.com/{owner}/{repo}/releases/download/{tag}/{asset}
    final segments = List<String>.from(uri.pathSegments);
    final isDownload = segments.length >= 5 &&
        segments[2] == 'releases' &&
        segments[3] == 'download';
    final out = template
        .replaceAll('{owner}', isDownload ? segments[0] : '')
        .replaceAll('{repo}', isDownload ? segments[1] : '')
        .replaceAll('{tag}', isDownload ? segments[4] : '')
        .replaceAll('{asset}', isDownload ? segments.sublist(5).join('/') : '');
    return _urls.validate(out).toString();
  }

  /// Probe durations for each candidate (small ranged GET; HEAD is not
  /// reliably supported by prefix proxies). Unreachable mirrors are omitted.
  Future<Map<String, Duration>> probeAll() async {
    final probeUrl = 'https://github.com/OpenTTD/OpenTTD/releases';
    final results = <String, Duration>{};
    await Future.wait(
      candidates().map((m) async {
        final sw = Stopwatch()..start();
        try {
          final url = _urls.validate(translate(probeUrl, m));
          await _dio.head(
            url.toString(),
            options: Options(
              sendTimeout: const Duration(seconds: 3),
              receiveTimeout: const Duration(seconds: 3),
              followRedirects: true,
              validateStatus: (s) => s != null && s < 500,
            ),
          );
          results[m.id] = sw.elapsed;
        } on DioException {
          // unreachable
        } on UrlInvalidFailure {
          // misconfigured mirror — excluded from probing
        }
      }),
    );
    return results;
  }

  /// Ordered mirror candidates for a download: auto-probe ordering when
  /// [probed] provided, otherwise configured weight order.
  List<MirrorConfig> orderForDownload({String strategy = 'auto', String? fixedId, Map<String, Duration>? probed}) {
    switch (strategy) {
      case 'fixed':
        final fixed = mirrors.where((m) => m.id == fixedId && m.enabled).toList();
        return [...fixed, ...candidates().where((m) => m.id != fixedId)];
      case 'official':
        return candidates().where((m) => m.id == builtinDirectMirrorId).toList();
      case 'fastest':
      case 'auto':
      default:
        if (probed == null || probed.isEmpty) return candidates();
        final byLatency = candidates().toList()
          ..sort((a, b) {
            final la = probed[a.id]?.inMicroseconds ?? 0x7FFFFFFFFFFFFFFF;
            final lb = probed[b.id]?.inMicroseconds ?? 0x7FFFFFFFFFFFFFFF;
            return la.compareTo(lb);
          });
        return byLatency;
    }
  }

  /// True when a mirror URL is a github.com URL passing through directly —
  /// used to decide whether the sha256 trust label can be tightened.
  static bool isDirect(MirrorConfig m) => m.id == builtinDirectMirrorId;
}
