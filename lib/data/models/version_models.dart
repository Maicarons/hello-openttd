import 'dart:io' show Platform;

/// A release offered by a version source, with per-platform assets.
class SourceRelease {
  SourceRelease({
    required this.version,
    required this.sourceId,
    this.releasedAt,
    this.prerelease = false,
    required this.assets,
  });

  final String version;
  final String sourceId;
  final DateTime? releasedAt;
  final bool prerelease;

  /// key = platform key such as `windows-x64`, `linux-x64`, `macos`.
  final Map<String, SourceAsset> assets;
}

class SourceAsset {
  SourceAsset({required this.url, this.size, this.sha256});

  final String url;
  final int? size;
  final String? sha256;
}

/// Platform target keys understood by the launcher.
class PlatformTarget {
  static const windowsX64 = 'windows-x64';
  static const windowsX86 = 'windows-x86';
  static const linuxX64 = 'linux-x64';
  static const linuxArm64 = 'linux-arm64';
  static const macos = 'macos';

  static String detect() {
    if (Platform.isWindows) return windowsX64;
    if (Platform.isMacOS) return macos;
    if (Platform.operatingSystemVersion.contains('arm64') ||
        Platform.operatingSystemVersion.contains('aarch64')) {
      return linuxArm64;
    }
    return linuxX64;
  }
}
