import '../../core/errors/failures.dart';
import '../../data/models/version_models.dart';

/// A provider of OpenTTD releases (official CDN, GitHub fork, URL list…).
abstract class VersionSource {
  String get id;
  String get name;

  /// Lists available releases (newest first).
  Future<List<SourceRelease>> listReleases();
}

/// Maps a distribution filename to one of our platform keys.
///
/// Mirrors the approach of the CDN itself: locate the OS keyword in the
/// filename (version numbers may contain hyphens, so no naive splitting).
String? platformKeyForFilename(String filename) {
  final lower = filename.toLowerCase();
  final isWindows = lower.contains('windows') || lower.contains('win64') || lower.contains('win32');
  final isLinux = lower.contains('linux');
  final isMac = lower.contains('macos') || lower.contains('osx') || lower.contains('darwin');
  if (!isWindows && !isLinux && !isMac) return null;

  final isArm = lower.contains('arm64') || lower.contains('aarch64');
  if (isWindows) {
    if (lower.contains('win32')) return PlatformTarget.windowsX86;
    return PlatformTarget.windowsX64;
  }
  if (isMac) return PlatformTarget.macos;
  return isArm ? PlatformTarget.linuxArm64 : PlatformTarget.linuxX64;
}

/// Chooses between multiple assets for the same platform by archive format
/// preference (zip is self-contained; linux prefers .tar.xz over .tar.gz).
int assetPreference(String filename) {
  final lower = filename.toLowerCase();
  if (lower.endsWith('.zip')) return 0;
  if (lower.endsWith('.tar.xz')) return 1;
  if (lower.endsWith('.tar.gz') || lower.endsWith('.tgz')) return 2;
  if (lower.endsWith('.dmg')) return 3;
  return 9;
}

/// Registers [asset] for [platform], keeping the most preferred filename.
void putAsset(Map<String, SourceAsset> assets, String platform, SourceAsset asset, String filename) {
  final existing = assets[platform];
  if (existing == null || assetPreference(filename) < assetPreference(existing.url)) {
    assets[platform] = asset;
  }
}

/// Common HTTP error mapping for all sources.
Never throwNetwork(Object error, String what) {
  throw NetworkFailure('$what: $error');
}

/// Classifies a version string (16.0-beta2 → prerelease).
bool isPrereleaseVersion(String version) {
  final lower = version.toLowerCase();
  return lower.contains('-beta') || lower.contains('-rc') || lower.contains('-alpha') ||
      lower.startsWith('beta') || lower.startsWith('rc') || lower.startsWith('alpha');
}
