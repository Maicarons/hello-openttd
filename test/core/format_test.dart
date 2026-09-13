import 'package:flutter_test/flutter_test.dart';
import 'package:hello_openttd/core/utils/format.dart';

void main() {
  group('formatBytes', () {
    test('formats ascending units', () {
      expect(formatBytes(null), '—');
      expect(formatBytes(512), '512 B');
      expect(formatBytes(2048), '2.0 KB');
      expect(formatBytes(5 * 1024 * 1024), '5.0 MB');
    });
  });

  group('compareVersions', () {
    test('orders dotted versions numerically', () {
      expect(compareVersions('1.10.0', '1.9.0'), greaterThan(0));
      expect(compareVersions('14.1', '14.1'), 0);
      expect(compareVersions('0.61.2', '0.61'), greaterThan(0));
      expect(compareVersions('16.0-beta2', '15.3'), greaterThan(0));
    });
  });
}
