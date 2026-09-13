import 'dart:io';

import 'package:path/path.dart' as p;

/// Resolved directory layout of the launcher's data root.
///
/// Portable mode is active when a folder named `OpenDepotData` (or an empty
/// `portable.flag` file) exists next to the launcher binary; in that case the
/// data root follows the program folder.
class AppPaths {
  AppPaths({required this.dataRoot, required this.portable});

  final Directory dataRoot;
  final bool portable;

  Directory get versionsDir => Directory(p.join(dataRoot.path, 'versions'));
  Directory get sharedDir => Directory(p.join(dataRoot.path, 'shared'));
  Directory get sharedConfigDir => Directory(p.join(sharedDir.path, 'config'));
  Directory get sharedSavesDir => Directory(p.join(sharedDir.path, 'saves'));
  Directory get backupsDir => Directory(p.join(sharedDir.path, 'backups'));
  Directory get cacheDir => Directory(p.join(dataRoot.path, 'cache'));
  Directory get downloadsDir => Directory(p.join(cacheDir.path, 'downloads'));
  Directory get bananasCacheDir => Directory(p.join(cacheDir.path, 'bananas'));
  Directory get logsDir => Directory(p.join(dataRoot.path, 'logs'));

  File get settingsFile => File(p.join(dataRoot.path, 'settings.json'));
  File get mirrorsFile => File(p.join(dataRoot.path, 'mirrors.json'));
  File get sharedModsFile => File(p.join(sharedDir.path, 'mods.json'));

  File get sharedConfigFile => File(p.join(sharedConfigDir.path, 'openttd.cfg'));

  Directory versionDir(String id) => Directory(p.join(versionsDir.path, id));

  /// Creates the standard directory skeleton (idempotent).
  Future<void> ensureAll() async {
    for (final d in [
      dataRoot,
      versionsDir,
      sharedDir,
      sharedConfigDir,
      sharedSavesDir,
      backupsDir,
      cacheDir,
      downloadsDir,
      bananasCacheDir,
      logsDir,
    ]) {
      if (!d.existsSync()) await d.create(recursive: true);
    }
  }
}

/// Locates the directory containing the running executable.
Directory executableDirectory() =>
    File(Platform.resolvedExecutable).parent;

/// Resolves the data root (portable mode first, platform default second).
Future<AppPaths> resolveAppPaths() async {
  final exeDir = executableDirectory();
  final portableDir = Directory(p.join(exeDir.path, 'OpenDepotData'));
  final portableFlag = File(p.join(exeDir.path, 'portable.flag'));
  final portable = portableDir.existsSync() || portableFlag.existsSync();

  final Directory root;
  if (portable) {
    root = portableDir.existsSync() ? portableDir : Directory(p.join(exeDir.path, 'OpenDepotData'));
  } else {
    root = Directory(defaultDataRootPath());
  }
  final paths = AppPaths(dataRoot: root, portable: portable);
  await paths.ensureAll();
  return paths;
}

/// Platform-default data root, as documented in the user guide.
String defaultDataRootPath() {
  if (Platform.isWindows) {
    final appData = Platform.environment['APPDATA'];
    return p.join(appData ?? '.', 'OpenDepot');
  }
  if (Platform.isMacOS) {
    final home = Platform.environment['HOME'] ?? '.';
    return p.join(home, 'Library', 'Application Support', 'OpenDepot');
  }
  final xdg = Platform.environment['XDG_DATA_HOME'];
  final home = Platform.environment['HOME'] ?? '.';
  return p.join(xdg ?? p.join(home, '.local', 'share'), 'opendepot');
}
