import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../core/paths/app_paths.dart';
import '../core/paths/fs_guard.dart';
import '../data/models/launcher_settings.dart';
import '../data/models/mirror_config.dart';
import '../data/repositories/repositories.dart';
import '../services/mirror/mirror_service.dart';
import '../services/security/url_validator.dart';

/// Resolved launcher directory layout (overridden in main / tests).
final appPathsProvider = Provider<AppPaths>(
  (ref) => throw UnimplementedError('appPathsProvider must be overridden'),
);

final fsGuardProvider = Provider<FsGuard>((ref) => const FsGuard());

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(appPathsProvider).settingsFile),
);

final mirrorsRepositoryProvider = Provider<MirrorsRepository>(
  (ref) => MirrorsRepository(ref.watch(appPathsProvider).mirrorsFile),
);

final runsRepositoryProvider = Provider<RunsRepository>(
  (ref) => RunsRepository(
    File(p.join(ref.watch(appPathsProvider).dataRoot.path, 'shared', 'runs.json')),
  ),
);

final settingsProvider = NotifierProvider<SettingsController, LauncherSettings>(
  SettingsController.new,
);

class SettingsController extends Notifier<LauncherSettings> {
  @override
  LauncherSettings build() => ref.watch(settingsRepositoryProvider).load();

  void update(LauncherSettings Function(LauncherSettings) fn) {
    final next = fn(state);
    ref.read(settingsRepositoryProvider).save(next);
    state = next;
  }
}

final mirrorsProvider =
    NotifierProvider<MirrorsController, List<MirrorConfig>>(MirrorsController.new);

class MirrorsController extends Notifier<List<MirrorConfig>> {
  @override
  List<MirrorConfig> build() => ref.watch(mirrorsRepositoryProvider).load();

  void update(List<MirrorConfig> mirrors) {
    ref.read(mirrorsRepositoryProvider).save(mirrors);
    state = mirrors;
  }

  void add(MirrorConfig mirror) => update([...state, mirror]);

  void remove(String id) => update([...state.where((m) => m.id != id)]);
}

final urlValidatorProvider = Provider<UrlValidator>(
  (ref) => const UrlValidator(allowLoopbackHttp: true),
);

final dioProvider = Provider<Dio>((ref) {
  final token = ref.watch(settingsProvider).githubToken;
  return Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'User-Agent': 'hello-openttd/0.1',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    },
  ));
});

final mirrorServiceProvider = Provider<MirrorService>(
  (ref) => MirrorService(
    mirrors: ref.watch(mirrorsProvider),
    dio: ref.watch(dioProvider),
    urls: ref.watch(urlValidatorProvider),
  ),
);
