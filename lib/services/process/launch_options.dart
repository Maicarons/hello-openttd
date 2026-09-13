import '../../data/models/version_manifest.dart';

enum LaunchMode { newGame, loadSave, joinServer, dedicated }

/// Pure argument builder — no shell, ever; user args go last verbatim
/// (docs/dev/process §1).
class LaunchOptions {
  const LaunchOptions({
    required this.version,
    required this.mode,
    this.sharedConfigPath,
    this.savePath,
    this.serverAddress,
    this.serverPassword,
    this.resolution,
    this.extraArgs = const [],
  });

  final VersionManifest version;
  final LaunchMode mode;

  /// Passed as `-c` when the version runs with a shared config.
  final String? sharedConfigPath;
  final String? savePath;
  final String? serverAddress;
  final String? serverPassword;
  final String? resolution;
  final List<String> extraArgs;

  /// Builds the OpenTTD command line for [options].
  static List<String> buildArguments(LaunchOptions options) {
    final args = <String>[];
    switch (options.mode) {
      case LaunchMode.newGame:
        args.add('-g');
      case LaunchMode.loadSave:
        args.addAll(['-g', options.savePath!]);
      case LaunchMode.joinServer:
        args.addAll(['-n', options.serverAddress!]);
        final pw = options.serverPassword;
        if (pw != null && pw.isNotEmpty) args.addAll(['-p', pw]);
      case LaunchMode.dedicated:
        args.add('-D');
        if (options.serverAddress != null && options.serverAddress!.isNotEmpty) {
          args.add(options.serverAddress!);
        }
    }
    if (options.version.configMode == 'shared' &&
        options.sharedConfigPath != null &&
        options.sharedConfigPath!.isNotEmpty) {
      args.addAll(['-c', options.sharedConfigPath!]);
    }
    if (options.resolution != null && options.resolution!.isNotEmpty) {
      args.addAll(['-r', options.resolution!]);
    }
    args.addAll(options.extraArgs);
    return args;
  }

  static String modeName(LaunchMode mode) => switch (mode) {
        LaunchMode.newGame => 'newGame',
        LaunchMode.loadSave => 'loadSave',
        LaunchMode.joinServer => 'joinServer',
        LaunchMode.dedicated => 'dedicated',
      };
}
