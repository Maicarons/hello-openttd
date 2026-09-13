import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../core/errors/failures.dart';
import '../data/models/version_manifest.dart';
import '../services/archive/archive_service.dart';
import '../services/bananas/bananas_service.dart';
import '../services/config/cfg_service.dart';
import '../services/download/download_engine.dart';
import '../services/process/process_service.dart';
import '../services/saves/save_service.dart';
import '../services/version_source/source_registry.dart';
import '../services/version_source/version_installer.dart';
import '../services/version_source/versions_service.dart';
import 'core_providers.dart';

export '../services/process/process_service.dart' show RunExit;

final archiveServiceProvider = Provider<ArchiveService>((ref) => ArchiveService());

final downloadEngineProvider = Provider<DownloadEngine>(
  (ref) => DownloadEngine(
    dio: ref.watch(dioProvider),
    mirrorService: ref.watch(mirrorServiceProvider),
    downloadDir: ref.watch(appPathsProvider).downloadsDir,
  ),
);

final versionsServiceProvider = Provider<VersionsService>(
  (ref) => VersionsService(paths: ref.watch(appPathsProvider)),
);

final versionInstallerProvider = Provider<VersionInstaller>(
  (ref) => VersionInstaller(
    paths: ref.watch(appPathsProvider),
    engine: ref.watch(downloadEngineProvider),
    archive: ref.watch(archiveServiceProvider),
  ),
);

final sourceRegistryProvider = Provider<SourceRegistry>(
  (ref) => SourceRegistry(dio: ref.watch(dioProvider)),
);

final cfgServiceProvider = Provider<CfgService>(
  (ref) => CfgService(paths: ref.watch(appPathsProvider)),
);

final processServiceProvider = Provider<ProcessService>(
  (ref) => ProcessService(
    paths: ref.watch(appPathsProvider),
    runsRepository: ref.watch(runsRepositoryProvider),
  ),
);

final saveServiceProvider = Provider<SaveService>(
  (ref) => SaveService(paths: ref.watch(appPathsProvider)),
);

final bananasServiceProvider = Provider<BananasService>(
  (ref) => BananasService(paths: ref.watch(appPathsProvider), dio: ref.watch(dioProvider)),
);

final installedVersionsProvider =
    NotifierProvider<InstalledVersionsController, AsyncValue<List<VersionManifest>>>(
  InstalledVersionsController.new,
);

class InstalledVersionsController extends Notifier<AsyncValue<List<VersionManifest>>> {
  @override
  AsyncValue<List<VersionManifest>> build() {
    Future.microtask(refresh);
    return const AsyncValue.loading();
  }

  void refresh() {
    state = const AsyncValue.loading();
    () async {
      try {
        final versions = ref.read(versionsServiceProvider).installed();
        state = AsyncValue.data(versions);
      } on Failure catch (e) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }();
  }
}

final selectedVersionIdProvider =
    NotifierProvider<SelectedVersionController, String?>(SelectedVersionController.new);

class SelectedVersionController extends Notifier<String?> {
  @override
  String? build() {
    final settings = ref.watch(settingsProvider);
    final installed = ref.watch(installedVersionsProvider).value ?? const <VersionManifest>[];
    if (installed.isEmpty) return null;
    final preferred = settings.defaultVersionId;
    if (preferred != null && installed.any((v) => v.id == preferred)) {
      return preferred;
    }
    return installed.first.id;
  }

  void select(String? id) => state = id;
}

final selectedVersionProvider = Provider<VersionManifest?>((ref) {
  final id = ref.watch(selectedVersionIdProvider);
  if (id == null) return null;
  final installed = ref.watch(installedVersionsProvider).value ?? const <VersionManifest>[];
  for (final v in installed) {
    if (v.id == id) return v;
  }
  return null;
});

/// Game directory of the currently selected version (null when none).
final selectedGameDirProvider = Provider<String?>((ref) {
  final version = ref.watch(selectedVersionProvider);
  if (version == null) return null;
  return p.dirname(version.binaryPath);
});
