/// Line-preserving parser for OpenTTD's INI-style config files.
///
/// Parsing builds a model of raw lines; editing mutates only targeted lines
/// so comments, blank lines and key ordering survive round-trips — unknown
/// content is never dropped (docs/dev/cfg-parser).
sealed class CfgLine {
  CfgLine(this.raw);
  final String raw;
}

class BlankLine extends CfgLine {
  BlankLine(super.raw);
}

class CommentLine extends CfgLine {
  CommentLine(super.raw);
}

class SectionLine extends CfgLine {
  SectionLine(super.raw, this.section);
  final String section;
}

class KeyValueLine extends CfgLine {
  KeyValueLine(this.section, this.key, this.value, super.raw);
  final String? section;
  final String key;
  String value;
}

class UnknownLine extends CfgLine {
  UnknownLine(super.raw);
}

class CfgDocument {
  CfgDocument(this.lines);

  final List<CfgLine> lines;

  static final _sectionRe = RegExp(r'^\s*\[\s*([A-Za-z0-9_-]+)\s*\]\s*$');
  static final _kvRe = RegExp(r'^(\s*)([A-Za-z0-9_.-]+)\s*=\s*(.*?)\s*$');

  /// Parses [text]; tolerant — malformed lines round-trip as [UnknownLine].
  factory CfgDocument.parse(String text) {
    final lines = <CfgLine>[];
    String? currentSection;
    for (final raw in text.split('\n')) {
      final sectionMatch = _sectionRe.firstMatch(raw);
      if (sectionMatch != null) {
        currentSection = sectionMatch.group(1)!;
        lines.add(SectionLine(raw, currentSection));
        continue;
      }
      final kv = _kvRe.firstMatch(raw);
      final trimmed = raw.trim();
      if (kv != null && !trimmed.startsWith('#') && !trimmed.startsWith(';')) {
        lines.add(KeyValueLine(currentSection, kv.group(2)!, kv.group(3) ?? '', raw));
      } else if (trimmed.isEmpty) {
        lines.add(BlankLine(raw));
      } else if (trimmed.startsWith('#') || trimmed.startsWith(';')) {
        lines.add(CommentLine(raw));
      } else if (_sectionRe.hasMatch(raw) == false && kv == null && trimmed.contains('[')) {
        lines.add(UnknownLine(raw));
      } else {
        lines.add(UnknownLine(raw));
      }
    }
    return CfgDocument(lines);
  }

  static CfgDocument empty() => CfgDocument([]);

  Iterable<KeyValueLine> entriesIn(String section) => lines
      .whereType<KeyValueLine>()
      .where((l) => (l.section ?? '') == section);

  Iterable<String> get sectionNames {
    final names = <String>[];
    for (final l in lines.whereType<SectionLine>()) {
      if (!names.contains(l.section)) names.add(l.section);
    }
    return names;
  }

  String? value(String section, String key) {
    for (final l in lines.whereType<KeyValueLine>()) {
      if ((l.section ?? '') == section && l.key == key) return l.value;
    }
    return null;
  }

  /// Sets a value, mutating the existing line in place when possible.
  void setValue(String section, String key, String value) {
    // 1) existing line with matching section+key → rewrite value only
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line is KeyValueLine && (line.section ?? '') == section && line.key == key) {
        line.value = value;
        final kv = _kvRe.firstMatch(line.raw);
        final indent = kv?.group(1) ?? '';
        lines[i] = KeyValueLine(section, key, value, '$indent$key = $value');
        return;
      }
    }
    // 2) section exists → append key after the section's last entry
    var lastInSection = -1;
    String? current;
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line is SectionLine) {
        current = line.section;
      } else if (line is KeyValueLine && current == section) {
        lastInSection = i;
      }
    }
    if (lastInSection >= 0) {
      lines.insert(lastInSection + 1, KeyValueLine(section, key, value, '$key = $value'));
      return;
    }
    // 3) create the section at the end
    lines.add(BlankLine(''));
    lines.add(SectionLine('[$section]', section));
    lines.add(KeyValueLine(section, key, value, '$key = $value'));
  }

  void removeKey(String section, String key) {
    lines.removeWhere(
        (l) => l is KeyValueLine && (l.section ?? '') == section && l.key == key);
  }

  /// Serializes back to text. Round-trips untouched documents byte-for-byte.
  String serialize() => lines.map((l) => l.raw).join('\n');
}
