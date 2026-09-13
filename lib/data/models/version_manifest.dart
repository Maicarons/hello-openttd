/// Minimal projection consumed by the process service (decouples it from
/// repository/manifest details).
abstract class VersionManifestLike {
  String get id;
  String get label;
  String get binaryPath;
}

/// Per-version manifest written by the launcher after a successful install.
class VersionManifest implements VersionManifestLike {
  VersionManifest({
    required this.id,
    required this.sourceId,
    required this.version,
    required this.platform,
    required this.installedAt,
    required this.binaryPath,
    this.sha256,
    this.verified = false,
    this.configMode = 'independent',
    this.launchCount = 0,
    this.lastLaunchedAt,
  });

  @override
  final String id;
  final String sourceId;
  final String version;
  final String platform;
  final DateTime installedAt;
  @override
  final String binaryPath;
  final String? sha256;

  /// True when the hash was checked against a pinned/declared value.
  final bool verified;
  final String configMode;
  int launchCount;
  DateTime? lastLaunchedAt;

  /// Display label, e.g. "official 14.1".
  @override
  String get label => '$sourceId $version';

  factory VersionManifest.fromJson(Map<String, dynamic> json) => VersionManifest(
        id: json['id'] as String,
        sourceId: json['sourceId'] as String,
        version: json['version'] as String,
        platform: json['platform'] as String,
        installedAt: DateTime.parse(json['installedAt'] as String),
        binaryPath: json['binaryPath'] as String,
        sha256: json['sha256'] as String?,
        verified: (json['verified'] as bool?) ?? false,
        configMode: (json['configMode'] as String?) ?? 'independent',
        launchCount: (json['launchCount'] as num?)?.toInt() ?? 0,
        lastLaunchedAt: json['lastLaunchedAt'] == null
            ? null
            : DateTime.parse(json['lastLaunchedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceId': sourceId,
        'version': version,
        'platform': platform,
        'installedAt': installedAt.toIso8601String(),
        'binaryPath': binaryPath,
        'sha256': sha256,
        'verified': verified,
        'configMode': configMode,
        'launchCount': launchCount,
        'lastLaunchedAt': lastLaunchedAt?.toIso8601String(),
      };
}
