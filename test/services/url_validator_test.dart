import 'package:flutter_test/flutter_test.dart';
import 'package:hello_openttd/core/errors/failures.dart';
import 'package:hello_openttd/services/security/url_validator.dart';

void main() {
  const strict = UrlValidator();
  const dev = UrlValidator(allowLoopbackHttp: true);

  test('accepts https urls', () {
    expect(strict.validate('https://cdn.openttd.org/latest.yaml').host,
        'cdn.openttd.org');
  });

  test('rejects http outside loopback', () {
    expect(() => strict.validate('http://cdn.openttd.org/x'),
        throwsA(isA<UrlInvalidFailure>()));
    expect(() => dev.validate('http://cdn.openttd.org/x'),
        throwsA(isA<UrlInvalidFailure>()));
  });

  test('loopback http only in dev mode', () {
    expect(() => strict.validate('http://127.0.0.1:8080/f'),
        throwsA(isA<UrlInvalidFailure>()));
    expect(dev.validate('http://127.0.0.1:8080/f').host, '127.0.0.1');
  });

  test('rejects userinfo, ip literals and dotless hosts', () {
    expect(() => strict.validate('https://user:pass@example.com/f'),
        throwsA(isA<UrlInvalidFailure>()));
    expect(() => strict.validate('https://192.168.1.1/f'),
        throwsA(isA<UrlInvalidFailure>()));
    expect(() => strict.validate('https://intranet/f'),
        throwsA(isA<UrlInvalidFailure>()));
  });

  test('rejects non-http schemes and garbage', () {
    expect(() => strict.validate('ftp://example.com/f'),
        throwsA(isA<UrlInvalidFailure>()));
    expect(() => strict.validate('file:///C:/x'),
        throwsA(isA<UrlInvalidFailure>()));
    expect(() => strict.validate('not a url'), throwsA(isA<UrlInvalidFailure>()));
  });

  test('blocks https→http downgrade redirects', () {
    final from = Uri.parse('https://example.com/a');
    expect(
      () => strict.validateRedirect(from, Uri.parse('http://example.com/b')),
      throwsA(isA<UrlInvalidFailure>()),
    );
    expect(
      strict.validateRedirect(from, Uri.parse('https://cdn.example.com/b')).host,
      'cdn.example.com',
    );
  });
}
