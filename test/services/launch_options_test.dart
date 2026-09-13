import 'package:flutter_test/flutter_test.dart';
import 'package:hello_openttd/data/models/version_manifest.dart';
import 'package:hello_openttd/services/process/launch_options.dart';

VersionManifest manifest({String configMode = 'independent'}) => VersionManifest(
      id: 'official-14.1',
      sourceId: 'official',
      version: '14.1',
      platform: 'windows-x64',
      installedAt: DateTime(2026, 9, 13),
      binaryPath: 'G:/data/versions/official-14.1/openttd.exe',
      configMode: configMode,
    );

void main() {
  final version = manifest();

  test('new game builds -g', () {
    expect(
      LaunchOptions.buildArguments(LaunchOptions(version: version, mode: LaunchMode.newGame)),
      ['-g'],
    );
  });

  test('load save passes the path after -g', () {
    expect(
      LaunchOptions.buildArguments(LaunchOptions(
        version: version,
        mode: LaunchMode.loadSave,
        savePath: 'G:/saves/city.sav',
      )),
      ['-g', 'G:/saves/city.sav'],
    );
  });

  test('join server supports password', () {
    expect(
      LaunchOptions.buildArguments(LaunchOptions(
        version: version,
        mode: LaunchMode.joinServer,
        serverAddress: 'server.example.com',
        serverPassword: 'secret',
      )),
      ['-n', 'server.example.com', '-p', 'secret'],
    );
  });

  test('dedicated server without address', () {
    expect(
      LaunchOptions.buildArguments(LaunchOptions(version: version, mode: LaunchMode.dedicated)),
      ['-D'],
    );
  });

  test('shared config injects -c', () {
    final shared = manifest(configMode: 'shared');
    expect(
      LaunchOptions.buildArguments(LaunchOptions(
        version: shared,
        mode: LaunchMode.newGame,
        sharedConfigPath: 'G:/data/shared/config/openttd.cfg',
      )),
      ['-g', '-c', 'G:/data/shared/config/openttd.cfg'],
    );
  });

  test('resolution and extra args appended last', () {
    expect(
      LaunchOptions.buildArguments(LaunchOptions(
        version: version,
        mode: LaunchMode.newGame,
        resolution: '1920x1080',
        extraArgs: const ['-d', '2'],
      )),
      ['-g', '-r', '1920x1080', '-d', '2'],
    );
  });
}
