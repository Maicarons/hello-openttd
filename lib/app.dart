import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/config_editor/config_page.dart';
import 'features/home/home_page.dart';
import 'features/launch/launch_page.dart';
import 'features/mods/mods_page.dart';
import 'features/saves/saves_page.dart';
import 'features/settings/settings_page.dart';
import 'features/versions/versions_page.dart';
import 'l10n/generated/app_localizations.dart';
import 'providers/core_providers.dart';
import 'ui/layout/app_shell.dart';
import 'ui/theme/app_theme.dart';

class HelloOpenTTDApp extends ConsumerStatefulWidget {
  const HelloOpenTTDApp({super.key});

  @override
  ConsumerState<HelloOpenTTDApp> createState() => _HelloOpenTTDAppState();
}

class _HelloOpenTTDAppState extends ConsumerState<HelloOpenTTDApp> {
  late final GoRouter _router = GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          _branch('/home', const HomePage()),
          _branch('/versions', const VersionsPage()),
          _branch('/launch', const LaunchPage()),
          _branch('/config', const ConfigPage()),
          _branch('/mods', const ModsPage()),
          _branch('/saves', const SavesPage()),
          _branch('/settings', const SettingsPage()),
        ],
      ),
    ],
  );

  StatefulShellBranch _branch(String path, Widget child) => StatefulShellBranch(
        routes: [
          GoRoute(
            path: path,
            builder: (context, state) => child,
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      title: 'hello-openttd',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: switch (settings.themeMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      locale: settings.locale == 'system' ? null : Locale(settings.locale),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
