import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/logging.dart';
import 'core/paths/app_paths.dart';
import 'providers/core_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final paths = await resolveAppPaths();
  initLogging(paths.logsDir);
  Log.info('OpenDepot starting; data root: ${redact(paths.dataRoot.path)}');
  runApp(
    ProviderScope(
      overrides: [appPathsProvider.overrideWithValue(paths)],
      child: const OpenDepotApp(),
    ),
  );
}
