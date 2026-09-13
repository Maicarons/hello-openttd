import 'package:flutter_test/flutter_test.dart';
import 'package:hello_openttd/services/config/cfg_document.dart';
import 'package:hello_openttd/services/config/key_catalog.dart';

const sampleCfg = '''
[misc]
display_opt = SHOW_TOWN_NAMES|FULL_ANIMATION
fullscreen = false

; player preferences below
[gui]
autosave = 12
autosave_on_exit = true

[network]
client_name = "Player"
''';

void main() {
  group('CfgDocument round-trip', () {
    test('untouched document serializes byte-identical', () {
      final doc = CfgDocument.parse(sampleCfg);
      expect(doc.serialize(), sampleCfg);
    });

    test('tolerates malformed lines without dropping them', () {
      const malformed = '[misc\nwhat is this line\ngarbage = = =\n';
      final doc = CfgDocument.parse(malformed);
      expect(doc.serialize(), malformed);
    });

    test('handles empty input', () {
      final doc = CfgDocument.parse('');
      expect(doc.sectionNames, isEmpty);
      expect(doc.serialize(), '');
    });
  });

  group('CfgDocument read', () {
    test('reads values by section and key', () {
      final doc = CfgDocument.parse(sampleCfg);
      expect(doc.value('misc', 'fullscreen'), 'false');
      expect(doc.value('gui', 'autosave'), '12');
      expect(doc.value('network', 'client_name'), '"Player"');
      expect(doc.value('gui', 'missing'), isNull);
    });

    test('lists sections in order', () {
      final doc = CfgDocument.parse(sampleCfg);
      expect(doc.sectionNames.toList(), ['misc', 'gui', 'network']);
    });
  });

  group('CfgDocument edit', () {
    test('editing one key changes only that line', () {
      final doc = CfgDocument.parse(sampleCfg);
      doc.setValue('gui', 'autosave', '6');
      final out = doc.serialize();
      expect(out, contains('autosave = 6'));
      expect(out, contains('; player preferences below'));
      expect(out, contains('display_opt = SHOW_TOWN_NAMES|FULL_ANIMATION'));
      // line count unchanged
      expect(out.split('\n').length, sampleCfg.split('\n').length);
    });

    test('adds a key to an existing section', () {
      final doc = CfgDocument.parse(sampleCfg);
      doc.setValue('gui', 'fast_vehicle_speed', 'true');
      final out = doc.serialize();
      expect(out, contains('fast_vehicle_speed = true'));
      // must be inside [gui], before [network]
      final guiIndex = out.indexOf('[gui]');
      final newKeyIndex = out.indexOf('fast_vehicle_speed');
      final networkIndex = out.indexOf('[network]');
      expect(newKeyIndex, greaterThan(guiIndex));
      expect(newKeyIndex, lessThan(networkIndex));
    });

    test('creates a missing section at the end', () {
      final doc = CfgDocument.parse(sampleCfg);
      doc.setValue('vehicle', 'max_trains', '100');
      expect(doc.serialize(), contains('[vehicle]'));
      expect(doc.value('vehicle', 'max_trains'), '100');
    });

    test('removeKey drops the line', () {
      final doc = CfgDocument.parse(sampleCfg);
      doc.removeKey('gui', 'autosave');
      expect(doc.value('gui', 'autosave'), isNull);
      expect(doc.serialize(), isNot(contains('autosave = 12')));
    });
  });

  group('key catalog', () {
    test('catalog keys have bilingual docs and valid types', () {
      for (final entry in keyCatalog) {
        expect(entry.labelZh, isNotEmpty, reason: entry.key);
        expect(entry.labelEn, isNotEmpty, reason: entry.key);
        expect(entry.docZh, isNotEmpty, reason: entry.key);
        expect(entry.docEn, isNotEmpty, reason: entry.key);
      }
    });
  });
}
