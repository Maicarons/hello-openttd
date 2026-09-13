import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hello_openttd/core/paths/app_paths.dart';
import 'package:hello_openttd/data/models/version_manifest.dart';
import 'package:hello_openttd/services/saves/save_service.dart';

void main() {
  late Directory tempDir;
  late AppPaths paths;
  late VersionManifest version;
  late SaveService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hello-openttd-saves');
    paths = AppPaths(dataRoot: tempDir, portable: true);
    await paths.ensureAll();

    final gameDir = Directory('${tempDir.path}/versions/official-14.1');
    gameDir.createSync(recursive: true);
    final binary = File('${gameDir.path}/openttd.exe');
    binary.writeAsStringSync('fake');

    version = VersionManifest(
      id: 'official-14.1',
      sourceId: 'official',
      version: '14.1',
      platform: 'windows-x64',
      installedAt: DateTime.now(),
      binaryPath: binary.path,
    );
    service = SaveService(paths: paths);
  });

  tearDown(() async {
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  File writeSave(String rel, String content) {
    final file = File('${tempDir.path}/versions/official-14.1/$rel');
    if (!file.parent.existsSync()) file.parent.createSync(recursive: true);
    file.writeAsStringSync(content);
    return file;
  }

  test('scan lists saves grouped by directory', () {
    writeSave('save/city.sav', 'a');
    writeSave('save/autosave/auto.sav', 'b');
    writeSave('scenario/map.scn', 'c');
    writeSave('save/ignored.txt', 'x');

    final entries = service.scan(version);
    expect(entries.length, 3);
    expect(entries.any((e) => e.group == 'autosave'), isTrue);
    expect(entries.any((e) => e.name == 'city'), isTrue);
  });

  test('import copies with collision suffix', () {
    writeSave('save/city.sav', 'existing');
    final incoming = Directory.systemTemp.tempPath('incoming.sav');
    File(incoming).writeAsStringSync('new data');

    final dest = service.import(version, incoming);
    expect(File(dest).readAsStringSync(), 'new data');
    // original untouched
    expect(File(incoming).readAsStringSync(), 'new data');
  });

  test('delete moves into launcher trash, not hard delete', () {
    final save = writeSave('save/doomed.sav', 'bye');
    final entry = service.scan(version).single;
    service.delete(entry);
    expect(save.existsSync(), isFalse);
    final trash = Directory('${tempDir.path}/shared/.trash');
    expect(trash.listSync().length, 1);
  });

  test('backup → restore round-trip', () {
    writeSave('save/city.sav', 'important data');
    writeSave('save/autosave/auto.sav', 'auto');

    final backup = service.backup(version);
    expect(backup.existsSync(), isTrue);
    expect(service.backups().length, 1);

    // Wipe and restore.
    Directory('${tempDir.path}/versions/official-14.1/save')
        .deleteSync(recursive: true);
    service.restore(version, backup);

    final restored = service.scan(version);
    expect(restored.any((e) => e.name == 'city'), isTrue);
    expect(restored.any((e) => e.group == 'autosave'), isTrue);
    expect(
      File('${tempDir.path}/versions/official-14.1/save/city.sav').readAsStringSync(),
      'important data',
    );
  });

  test('restore keeps a safety copy of overwritten files', () {
    writeSave('save/city.sav', 'important');
    final backup = service.backup(version);
    writeSave('save/city.sav', 'overwritten');

    service.restore(version, backup);
    expect(
      File('${tempDir.path}/versions/official-14.1/save/city.sav').readAsStringSync(),
      'important',
    );
    expect(
      Directory('${tempDir.path}/versions/official-14.1/save')
          .listSync()
          .whereType<File>()
          .any((f) => f.path.endsWith('.restore-bak')),
      isTrue,
    );
  });
}

extension _TempPath on Directory {
  String tempPath(String name) => '$path/$name';
}
