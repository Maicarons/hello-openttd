import 'package:flutter_test/flutter_test.dart';
import 'package:hello_openttd/core/errors/failures.dart';
import 'package:hello_openttd/core/paths/fs_guard.dart';

void main() {
  const guard = FsGuard();
  const root = '/data/root';

  group('isValidFilename', () {
    test('accepts normal names including unicode', () {
      expect(FsGuard.isValidFilename('openttd-14.1'), isTrue);
      expect(FsGuard.isValidFilename('我的存档 sav_1'), isTrue);
      expect(FsGuard.isValidFilename('Ünïcode'), isTrue);
      // Regression: `'\0'` in Dart is the digit '0', not NUL — names with
      // '0' (e.g. OpenTTD's compat_0.7.nut) must be accepted.
      expect(FsGuard.isValidFilename('compat_0.7.nut'), isTrue);
      expect(FsGuard.isValidFilename('a0b'), isTrue);
      expect(FsGuard.isValidFilename('x07'), isTrue);
    });

    test('rejects traversal and separators', () {
      expect(FsGuard.isValidFilename('..'), isFalse);
      expect(FsGuard.isValidFilename('.'), isFalse);
      expect(FsGuard.isValidFilename('a/b'), isFalse);
      expect(FsGuard.isValidFilename(r'a\b'), isFalse);
      expect(FsGuard.isValidFilename('a:b'), isFalse);
      expect(FsGuard.isValidFilename('a/../b'), isFalse);
    });

    test('rejects control characters and reserved device names', () {
      expect(FsGuard.isValidFilename('a\x00b'), isFalse);
      expect(FsGuard.isValidFilename('a\nb'), isFalse);
      expect(FsGuard.isValidFilename('CON'), isFalse);
      expect(FsGuard.isValidFilename('nul.txt'), isFalse);
      expect(FsGuard.isValidFilename('COM1'), isFalse);
    });

    test('rejects empty/oversized/dot-edge names', () {
      expect(FsGuard.isValidFilename(''), isFalse);
      expect(FsGuard.isValidFilename('a' * 129), isFalse);
      expect(FsGuard.isValidFilename('.hidden'), isFalse);
      expect(FsGuard.isValidFilename('trailing.'), isFalse);
      expect(FsGuard.isValidFilename('   '), isFalse);
    });
  });

  group('safeJoin', () {
    test('joins valid names under root', () {
      expect(guard.safeJoin(root, 'openttd-14.1'), contains('openttd-14.1'));
    });

    test('throws on traversal attempts', () {
      expect(() => guard.safeJoin(root, '../escape'), throwsA(isA<PathGuardFailure>()));
      expect(() => guard.safeJoin(root, 'sub/../..'), throwsA(isA<PathGuardFailure>()));
      expect(() => guard.safeJoin(root, 'C:evil'), throwsA(isA<PathGuardFailure>()));
    });
  });

  group('safeJoinAll', () {
    test('accepts nested relative paths', () {
      expect(
        guard.safeJoinAll(root, ['save', 'autosave', 'a.sav']),
        contains('a.sav'),
      );
    });

    test('rejects escaping components anywhere in the chain', () {
      expect(
        () => guard.safeJoinAll(root, ['save', '..', '..', 'etc']),
        throwsA(isA<PathGuardFailure>()),
      );
    });
  });

  test('isValidId enforces strict charset', () {
    expect(FsGuard.isValidId('official-14.1'), isTrue);
    expect(FsGuard.isValidId('Official'), isFalse);
    expect(FsGuard.isValidId('-lead'), isFalse);
    expect(FsGuard.isValidId('a b'), isFalse);
  });
}
