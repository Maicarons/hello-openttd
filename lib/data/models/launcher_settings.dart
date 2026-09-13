/// Launcher-wide settings persisted in `<data-root>/settings.json`.
class LauncherSettings {
  LauncherSettings({
    this.schemaVersion = 1,
    this.locale = 'system',
    this.themeMode = 'system',
    this.mirrorStrategy = 'auto',
    this.fixedMirrorId,
    this.defaultVersionId,
    this.githubToken = '',
    this.closeAfterLaunch = false,
    this.autosaveKeep = 20,
  });

  final int schemaVersion;
  final String locale;
  final String themeMode;
  final String mirrorStrategy;
  final String? fixedMirrorId;
  final String? defaultVersionId;
  final String githubToken;
  final bool closeAfterLaunch;
  final int autosaveKeep;

  LauncherSettings copyWith({
    String? locale,
    String? themeMode,
    String? mirrorStrategy,
    String? fixedMirrorId,
    Object? defaultVersionId = _sentinel,
    String? githubToken,
    bool? closeAfterLaunch,
    int? autosaveKeep,
  }) =>
      LauncherSettings(
        schemaVersion: schemaVersion,
        locale: locale ?? this.locale,
        themeMode: themeMode ?? this.themeMode,
        mirrorStrategy: mirrorStrategy ?? this.mirrorStrategy,
        fixedMirrorId: fixedMirrorId ?? this.fixedMirrorId,
        defaultVersionId: defaultVersionId == _sentinel
            ? this.defaultVersionId
            : defaultVersionId as String?,
        githubToken: githubToken ?? this.githubToken,
        closeAfterLaunch: closeAfterLaunch ?? this.closeAfterLaunch,
        autosaveKeep: autosaveKeep ?? this.autosaveKeep,
      );
  static const _sentinel = Object();

  factory LauncherSettings.fromJson(Map<String, dynamic> json) => LauncherSettings(
        schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
        locale: (json['locale'] as String?) ?? 'system',
        themeMode: (json['themeMode'] as String?) ?? 'system',
        mirrorStrategy: (json['mirrorStrategy'] as String?) ?? 'auto',
        fixedMirrorId: json['fixedMirrorId'] as String?,
        defaultVersionId: json['defaultVersionId'] as String?,
        githubToken: (json['githubToken'] as String?) ?? '',
        closeAfterLaunch: (json['closeAfterLaunch'] as bool?) ?? false,
        autosaveKeep: (json['autosaveKeep'] as num?)?.toInt() ?? 20,
      );

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'locale': locale,
        'themeMode': themeMode,
        'mirrorStrategy': mirrorStrategy,
        'fixedMirrorId': fixedMirrorId,
        'defaultVersionId': defaultVersionId,
        'githubToken': githubToken,
        'closeAfterLaunch': closeAfterLaunch,
        'autosaveKeep': autosaveKeep,
      };
}
