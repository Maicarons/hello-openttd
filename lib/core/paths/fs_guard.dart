import 'package:path/path.dart' as p;

import '../errors/failures.dart';

/// Single entry point for turning user-controlled strings into filesystem
/// paths under a trusted root. Every service must construct paths through
/// [safeJoin] — never with raw string interpolation (see docs/dev/security).
class FsGuard {
  const FsGuard();

  static final _reservedWindows = RegExp(
    r'^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(\..*)?$',
    caseSensitive: false,
  );

  /// Returns true when [name] may be used as a single path component.
  ///
  /// Allowed: letters/digits (incl. Unicode letters), `.` `_` `-` and space;
  /// 1–128 chars; no separators, no `..`, no Windows reserved device names.
  static bool isValidFilename(String name) {
    if (name.isEmpty || name.length > 128) return false;
    if (name == '.' || name == '..') return false;
    if (name.contains('/') || name.contains(r'\') || name.contains(':')) return false;
    if (name.contains('\0') || name.codeUnits.any((c) => c < 0x20)) return false;
    if (name.startsWith('.') || name.endsWith('.')) return false;
    if (_reservedWindows.hasMatch(name)) return false;
    // Whitespace-only names are meaningless and error-prone.
    if (name.trim().isEmpty) return false;
    final c = name.runes.first;
    final letterOrDigit =
        (c >= 0x30 && c <= 0x39) || (c >= 0x41 && c <= 0x5A) || (c >= 0x61 && c <= 0x7A);
    if (!letterOrDigit && !_isUnicodeLetter(c)) return false;
    return true;
  }

  static bool _isUnicodeLetter(int rune) =>
      RegExp(r'^\p{L}', unicode: true).hasMatch(String.fromCharCode(rune));

  /// Internal ids (version ids, mirror ids, task ids) — stricter charset.
  static bool isValidId(String id) =>
      RegExp(r'^[a-z0-9][a-z0-9._-]{0,63}$').hasMatch(id);

  /// Resolves [name] as a single component under [root], enforcing containment.
  ///
  /// Throws [PathGuardFailure] on any violation.
  String safeJoin(String root, String name) {
    if (!isValidFilename(name)) {
      throw PathGuardFailure('Rejected unsafe filename: "$name"');
    }
    final joined = p.normalize(p.join(root, name));
    if (!p.isWithin(p.normalize(root), joined)) {
      throw PathGuardFailure('Path escapes root: "$name"');
    }
    return joined;
  }

  /// Validates an arbitrary relative sub-path (e.g. `save/autosave`) made of
  /// validated components, enforcing containment under [root].
  String safeJoinAll(String root, List<String> components) {
    var current = p.normalize(root);
    for (final c in components) {
      if (!isValidFilename(c)) {
        throw PathGuardFailure('Rejected unsafe path component: "$c"');
      }
      current = p.normalize(p.join(current, c));
    }
    if (!p.isWithin(p.normalize(root), current)) {
      throw PathGuardFailure('Path escapes root: "$components"');
    }
    return current;
  }
}
