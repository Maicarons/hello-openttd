import 'dart:io';

import '../../core/errors/failures.dart';

/// Validates every outbound URL before any request is made.
///
/// Policy (docs/dev/security §4): https-only (loopback http allowed in debug
/// builds), no userinfo, no IP-literal hosts, hostname must contain a dot.
class UrlValidator {
  const UrlValidator({this.allowLoopbackHttp = false});

  /// Debug builds may talk to a local test server over http.
  final bool allowLoopbackHttp;

  /// Returns the validated [Uri] or throws [UrlInvalidFailure].
  Uri validate(String raw) {
    final Uri uri;
    try {
      uri = Uri.parse(raw.trim());
    } on FormatException catch (e) {
      throw UrlInvalidFailure('Unparseable URL "$raw": ${e.message}');
    }
    return validateUri(uri, raw: raw);
  }

  Uri validateUri(Uri uri, {String? raw}) {
    final source = raw ?? uri.toString();
    final scheme = uri.scheme.toLowerCase();
    final isLoopback =
        uri.host == 'localhost' || uri.host == '127.0.0.1' || uri.host == '[::1]';
    if (scheme == 'http') {
      if (!(allowLoopbackHttp && isLoopback)) {
        throw UrlInvalidFailure('Insecure scheme http: $source');
      }
    } else if (scheme != 'https') {
      throw UrlInvalidFailure('Unsupported scheme "$scheme": $source');
    }

    if (uri.userInfo.isNotEmpty) {
      throw UrlInvalidFailure('userinfo not allowed: $source');
    }
    if (uri.host.isEmpty) {
      throw UrlInvalidFailure('missing host: $source');
    }
    final host = uri.host;
    final isIpLiteral =
        InternetAddress.tryParse(host) != null ||
        (host.startsWith('[') && host.endsWith(']'));
    if (isIpLiteral && !(allowLoopbackHttp && isLoopback)) {
      throw UrlInvalidFailure('IP-literal host not allowed: $source');
    }
    if (!isLoopback && !host.contains('.')) {
      throw UrlInvalidFailure('hostname lacks dot: $source');
    }
    return uri;
  }

  /// Validates a redirect target: cross-origin re-validation plus an explicit
  /// https → http downgrade ban.
  Uri validateRedirect(Uri from, Uri to) {
    final validated = validateUri(to);
    if (from.scheme.toLowerCase() == 'https' &&
        validated.scheme.toLowerCase() == 'http') {
      throw UrlInvalidFailure('https→http downgrade blocked: ${validated.toString()}');
    }
    return validated;
  }
}
