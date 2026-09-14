import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/logging.dart';
import 'core/paths/app_paths.dart';
import 'providers/core_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Desktop window experience: fixed minimum size, sensible default size,
  // centered first launch, proper window title.
  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(1020, 680),
    center: true,
    title: 'hello-openttd',
    titleBarStyle: TitleBarStyle.normal,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  final paths = await resolveAppPaths();
  initLogging(paths.logsDir);
  Log.info('hello-openttd starting; data root: ${redact(paths.dataRoot.path)}');
  runApp(
    ProviderScope(
      overrides: [appPathsProvider.overrideWithValue(paths)],
      child: const HelloOpenTTDApp(),
    ),
  );
}
