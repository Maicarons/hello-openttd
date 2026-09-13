import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:opendepot/data/models/launcher_settings.dart';
import 'package:opendepot/data/models/mirror_config.dart';
import 'package:opendepot/data/models/run_record.dart';
import 'package:opendepot/data/repositories/repositories.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('opendepot-repo');
  });

  tearDown(() async {
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  test('settings round-trip preserves all fields', () {
    final repo = SettingsRepository(File('${tempDir.path}/settings.json'));
    final settings = LauncherSettings(
      locale: 'zh',
      themeMode: 'dark',
      mirrorStrategy: 'fixed',
      fixedMirrorId: 'm1',
      defaultVersionId: 'official-14.1',
      githubToken: 'ghp_test',
      closeAfterLaunch: true,
      autosaveKeep: 10,
    );
    repo.save(settings);
    final loaded = repo.load();
    expect(loaded.locale, 'zh');
    expect(loaded.themeMode, 'dark');
    expect(loaded.mirrorStrategy, 'fixed');
    expect(loaded.fixedMirrorId, 'm1');
    expect(loaded.defaultVersionId, 'official-14.1');
    expect(loaded.githubToken, 'ghp_test');
    expect(loaded.closeAfterLaunch, isTrue);
    expect(loaded.autosaveKeep, 10);
  });

  test('missing settings file yields defaults', () {
    final repo = SettingsRepository(File('${tempDir.path}/none.json'));
    expect(repo.load().locale, 'system');
  });

  test('mirrors round-trip; empty file yields built-in defaults', () {
    final repo = MirrorsRepository(File('${tempDir.path}/mirrors.json'));
    expect(repo.load().map((m) => m.id), contains('direct'));

    repo.save([
      MirrorConfig(id: 'm1', name: 'acc', template: 'https://x/{url}'),
    ]);
    expect(repo.load().single.id, 'm1');
  });

  test('runs repository appends, updates and trims', () {
    final repo = RunsRepository(File('${tempDir.path}/runs.json'), maxRecords: 3);
    RunRecord record(int i) => RunRecord(
          id: 'r$i',
          versionId: 'v',
          versionLabel: 'v',
          mode: 'newGame',
          args: const ['-g'],
          startedAt: DateTime(2026, 1, 1, 0, 0, i),
          logPath: '/tmp/log',
        );

    for (var i = 0; i < 5; i++) {
      repo.append(record(i));
    }
    var all = repo.load();
    expect(all.length, 3);
    expect(all.last.id, 'r4');

    final updating = all.last..exitCode = 3;
    updating.exitedAt = DateTime(2026, 1, 2);
    repo.update(updating);
    all = repo.load();
    expect(all.last.exitCode, 3);
    expect(all.last.running, isFalse);
  });

  test('corrupt json surfaces ParseFailure instead of crashing', () {
    final file = File('${tempDir.path}/bad.json')..writeAsStringSync('{oops');
    final repo = SettingsRepository(file);
    expect(() => repo.load(), throwsException);
  });
}
