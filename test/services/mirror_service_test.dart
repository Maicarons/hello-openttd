import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hello_openttd/core/errors/failures.dart';
import 'package:hello_openttd/data/models/mirror_config.dart';
import 'package:hello_openttd/services/mirror/mirror_service.dart';
import 'package:hello_openttd/services/security/url_validator.dart';

void main() {
  final dio = Dio();
  const githubUrl =
      'https://github.com/OpenTTD/OpenTTD/releases/download/14.1/openttd-14.1-windows-win64.zip';

  MirrorService service(List<MirrorConfig> mirrors) => MirrorService(
        mirrors: mirrors,
        dio: dio,
        urls: const UrlValidator(allowLoopbackHttp: true),
      );

  test('direct mirror returns the url unchanged', () {
    final s = service(defaultMirrors());
    expect(s.translate(githubUrl, s.candidates().last), githubUrl);
  });

  test('prefix template wraps the original url', () {
    final s = service([
      MirrorConfig(id: 'm1', name: 'acc', template: 'https://ghfast.net/{url}'),
      defaultMirrors().first,
    ]);
    final out = s.translate(githubUrl, s.candidates().first);
    expect(out, startsWith('https://ghfast.net/https://github.com/'));
  });

  test('rewrite template substitutes github path segments', () {
    final s = service([
      MirrorConfig(
        id: 'm2',
        name: 'rewrite',
        template: 'https://mirror.example.com/github/{owner}/{repo}/releases/download/{tag}/{asset}',
      ),
      defaultMirrors().first,
    ]);
    final out = s.translate(githubUrl, s.candidates().first);
    expect(out,
        'https://mirror.example.com/github/OpenTTD/OpenTTD/releases/download/14.1/openttd-14.1-windows-win64.zip');
  });

  test('mirror templates are url-validated (http template rejected)', () {
    final s = service([
      MirrorConfig(id: 'bad', name: 'bad', template: 'http://insecure/{url}'),
      defaultMirrors().first,
    ]);
    expect(
      () => s.translate(githubUrl, s.candidates().first),
      throwsA(isA<UrlInvalidFailure>()),
    );
  });

  test('candidates order: enabled mirrors by weight, direct last', () {
    final s = service([
      defaultMirrors().first, // direct, weight 10
      MirrorConfig(id: 'a', name: 'a', template: 'https://a.example/{url}', weight: 1),
      MirrorConfig(id: 'b', name: 'b', template: 'https://b.example/{url}', weight: 5, enabled: false),
    ]);
    expect(s.candidates().map((m) => m.id).toList(), ['a', 'direct']);
  });

  test('official-only strategy excludes mirrors', () {
    final s = service(defaultMirrors());
    final order = s.orderForDownload(strategy: 'official');
    expect(order.map((m) => m.id), ['direct']);
  });

  test('probed latency reorders candidates', () {
    final s = service(defaultMirrors());
    final order = s.orderForDownload(
      strategy: 'auto',
      probed: {'ghfast': const Duration(milliseconds: 20), 'direct': const Duration(seconds: 2)},
    );
    expect(order.first.id, 'ghfast');
  });
}
