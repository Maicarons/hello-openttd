// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'hello-openttd';

  @override
  String get navHome => 'Home';

  @override
  String get navVersions => 'Versions';

  @override
  String get navLaunch => 'Launch';

  @override
  String get navConfig => 'Config';

  @override
  String get navMods => 'Mods';

  @override
  String get navSaves => 'Saves';

  @override
  String get navSettings => 'Settings';

  @override
  String get refresh => 'Refresh';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get search => 'Search';

  @override
  String get openFolder => 'Open folder';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied';

  @override
  String get install => 'Install';

  @override
  String get uninstall => 'Uninstall';

  @override
  String get launch => 'Launch';

  @override
  String get browse => 'Browse';

  @override
  String get import => 'Import';

  @override
  String get export => 'Export';

  @override
  String get backup => 'Backup';

  @override
  String get restore => 'Restore';

  @override
  String get confirm => 'Confirm';

  @override
  String get loading => 'Loading…';

  @override
  String get empty => 'Nothing here yet';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorNetwork =>
      'Network error. Check your connection or switch mirrors.';

  @override
  String get errorTimeout => 'Connection timed out.';

  @override
  String get errorChecksum =>
      'Checksum verification failed; installation aborted.';

  @override
  String get errorPath => 'Unsafe path detected; operation rejected.';

  @override
  String get errorDisk => 'Disk read/write failed.';

  @override
  String get errorParse => 'Failed to parse data.';

  @override
  String get errorUrlInvalid => 'Invalid URL or unsupported protocol.';

  @override
  String get errorProcess => 'Failed to start process.';

  @override
  String get errorNotFound => 'Not found.';

  @override
  String get errorConflict => 'Target already exists.';

  @override
  String get errorCancelled => 'Operation cancelled.';

  @override
  String get errorUnknown => 'An unknown error occurred.';

  @override
  String get errorDiskFull => 'Not enough disk space.';

  @override
  String get homeTitle => 'Launch Deck';

  @override
  String get homeSelectVersion => 'Select an installed version';

  @override
  String get homeNoVersions =>
      'No versions installed yet.\nHead to Versions to install one.';

  @override
  String get homeLaunch => 'Launch game';

  @override
  String get homeRecentRuns => 'Recent runs';

  @override
  String homeLastLaunched(String time) {
    return 'Last launched: $time';
  }

  @override
  String get homeStatsVersions => 'Versions';

  @override
  String get homeStatsRuns => 'Total launches';

  @override
  String get homeStatsUnverified => 'Unverified hashes';

  @override
  String get versionsTitle => 'Version Management';

  @override
  String get versionsSource => 'Source';

  @override
  String get versionsInstallHint => 'Pick a source, then install a release.';

  @override
  String get versionsAvailable => 'Available releases';

  @override
  String get versionsInstalled => 'Installed';

  @override
  String get versionsLatest => 'latest';

  @override
  String get versionsUpdateAvailable => 'Update available';

  @override
  String get versionsUpToDate => 'Up to date';

  @override
  String get versionsLocal => 'Local';

  @override
  String versionsInstallConfirmTitle(String version) {
    return 'Install $version?';
  }

  @override
  String get versionsInstallConfirmBody =>
      'The archive will be downloaded and extracted into the data root. Assets with a declared SHA-256 are verified before install.';

  @override
  String get versionsUnverifiedHash =>
      'This asset provides no checksum; its hash will be recorded as \"unverified\".';

  @override
  String versionsUninstallConfirmTitle(String version) {
    return 'Uninstall $version?';
  }

  @override
  String get versionsUninstallBody => 'The version directory will be deleted.';

  @override
  String get versionsUninstallWithData =>
      'Also delete this version\'s config and saves';

  @override
  String get versionsDownloading => 'Downloading';

  @override
  String get versionsVerifying => 'Verifying…';

  @override
  String get versionsExtracting => 'Extracting…';

  @override
  String get versionsFinishing => 'Finishing…';

  @override
  String get versionsInstallDone => 'Installed';

  @override
  String get versionsAdopt => 'Add local version';

  @override
  String get versionsAdoptHint =>
      'Point at an existing OpenTTD directory (containing the openttd executable).';

  @override
  String get versionsConfigIndependent => 'Independent config';

  @override
  String get versionsConfigShared => 'Shared config';

  @override
  String get versionsPreRelease => 'Pre-release';

  @override
  String get versionsStable => 'Stable';

  @override
  String get launchTitle => 'Launch';

  @override
  String get launchMode => 'Launch mode';

  @override
  String get launchModeNewGame => 'New game';

  @override
  String get launchModeLoadSave => 'Load save';

  @override
  String get launchModeJoinServer => 'Join server';

  @override
  String get launchModeDedicated => 'Dedicated server';

  @override
  String get launchServerAddress => 'Server address (host[:port])';

  @override
  String get launchServerPassword => 'Server password (optional)';

  @override
  String get launchResolution => 'Resolution (e.g. 1920x1080)';

  @override
  String get launchExtraArgs => 'Extra arguments (appended verbatim)';

  @override
  String get launchPreview => 'Command preview';

  @override
  String get launchRun => '▶ Launch';

  @override
  String get launchRunningWarningShared =>
      'Running multiple instances with a shared config may overwrite settings. Continue?';

  @override
  String get launchRuns => 'Run records';

  @override
  String launchRunExit(int code) {
    return 'Exit code $code';
  }

  @override
  String get launchRunRunning => 'Running';

  @override
  String get launchStop => 'Terminate';

  @override
  String get launchViewLog => 'View log';

  @override
  String get launchNoRuns => 'No runs yet.';

  @override
  String get launchSelectSave => 'Pick a save';

  @override
  String get configTitle => 'Config Editor';

  @override
  String get configNoVersion => 'Select a version first.';

  @override
  String get configFormView => 'Form view';

  @override
  String get configRawView => 'Raw view';

  @override
  String get configSearchHint => 'Search keys or docs…';

  @override
  String get configSaveHint => 'A .bak backup is created before every save.';

  @override
  String configSaved(String backup) {
    return 'Saved (backup: $backup)';
  }

  @override
  String get configSavedNoBackup => 'Saved';

  @override
  String configInvalidValue(String value) {
    return 'Invalid value: $value';
  }

  @override
  String get configOtherKeys => 'Other keys (raw editing)';

  @override
  String get configSection => 'Section';

  @override
  String get modsTitle => 'Mod Center';

  @override
  String get modsTypeNewgrf => 'NewGRF';

  @override
  String get modsTypeAi => 'AI';

  @override
  String get modsTypeGameScript => 'GameScript';

  @override
  String get modsTypeMusic => 'Music sets';

  @override
  String get modsTabOnline => 'Online (BaNaNaS)';

  @override
  String get modsTabInstalled => 'Installed';

  @override
  String get modsSearchHint => 'Search name, author, description…';

  @override
  String get modsDownloadInGame =>
      'BaNaNaS does not expose direct download links (content ships in-game). Open the package page below, or install via the game\'s Content Download window.';

  @override
  String get modsOpenWeb => 'Open web page';

  @override
  String get modsImportLocal => 'Import local file';

  @override
  String get modsImportHint =>
      'Accepts .tar (BaNaNaS packages) and .grf; files are copied into this version\'s content_download directory.';

  @override
  String modsImported(String path) {
    return 'Imported: $path';
  }

  @override
  String modsDeleteConfirm(String name) {
    return 'Delete $name?';
  }

  @override
  String get modsInstalledEmpty => 'No content installed for this version yet.';

  @override
  String get modsVersions => 'Version';

  @override
  String get modsBy => 'By';

  @override
  String get savesTitle => 'Save Management';

  @override
  String get savesEmpty => 'No saves yet. Start a game to create one.';

  @override
  String get savesSearchHint => 'Search by name…';

  @override
  String get savesGroupSaves => 'Saves';

  @override
  String get savesGroupAutosave => 'Autosaves';

  @override
  String get savesGroupScenarios => 'Scenarios';

  @override
  String get savesGroupHeightmaps => 'Heightmaps';

  @override
  String savesDeleteConfirm(String name) {
    return 'Delete $name? (moved to launcher trash)';
  }

  @override
  String savesBackupDone(String name) {
    return 'Backup created: $name';
  }

  @override
  String get savesBackups => 'Backups';

  @override
  String get savesBackupsEmpty => 'No backups yet.';

  @override
  String get savesRestoreDone => 'Restored';

  @override
  String get savesImportPick => 'Choose .sav / .scn files to import';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsDataRoot => 'Data root';

  @override
  String get settingsPortable => 'Portable mode';

  @override
  String get settingsOpenDataRoot => 'Open data root';

  @override
  String get settingsDownloads => 'Downloads & Mirrors';

  @override
  String get settingsMirrorStrategy => 'Mirror strategy';

  @override
  String get settingsMirrorAuto => 'Auto (probe & pick)';

  @override
  String get settingsMirrorFastest => 'Fastest';

  @override
  String get settingsMirrorFixed => 'Fixed mirror';

  @override
  String get settingsMirrorOfficial => 'Official only';

  @override
  String get settingsMirrors => 'Mirrors';

  @override
  String get settingsAddMirror => 'Add mirror';

  @override
  String get settingsMirrorName => 'Name';

  @override
  String settingsMirrorTemplate(String url) {
    return 'URL template ($url placeholder)';
  }

  @override
  String get settingsGithubToken => 'GitHub token (optional)';

  @override
  String get settingsGithubTokenHint =>
      'Stored locally only; raises API rate limits. Logs are redacted.';

  @override
  String get settingsAdvanced => 'Advanced';

  @override
  String get settingsOpenLogs => 'Open log folder';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutBody =>
      'hello-openttd — an open-source OpenTTD launcher (AGPL-3.0). Not affiliated with the OpenTTD team.';

  @override
  String get settingsMirrorAdded => 'Mirror added';

  @override
  String get settingsProbeNow => 'Probe now';

  @override
  String settingsProbeResult(String name, int ms) {
    return '$name: $ms ms';
  }

  @override
  String settingsProbeFailed(String name) {
    return '$name: unreachable';
  }

  @override
  String get downloadUnverifiedLabel => 'unverified';

  @override
  String get downloadVerifiedLabel => 'verified';

  @override
  String versionLabelFormat(String source, String version) {
    return '$source $version';
  }
}
