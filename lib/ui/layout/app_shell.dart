import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';

/// NavigationRail desktop shell hosting the seven main pages via
/// StatefulShellRoute (go_router).
///
/// Keyboard: Ctrl+1..7 switches pages, Ctrl+, opens settings — matching the
/// shortcuts documented in the user guide.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const _icons = [
    Icons.rocket_launch_outlined,
    Icons.inventory_2_outlined,
    Icons.play_circle_outline,
    Icons.tune,
    Icons.extension_outlined,
    Icons.save_outlined,
    Icons.settings_outlined,
  ];

  void _go(int index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final titles = [
      l.navHome,
      l.navVersions,
      l.navLaunch,
      l.navConfig,
      l.navMods,
      l.navSaves,
      l.navSettings,
    ];
    final selectedIndex = navigationShell.currentIndex;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        for (var i = 0; i < 7; i++)
          SingleActivator(LogicalKeyboardKey(0x31 + i), control: true): () => _go(i),
        const SingleActivator(LogicalKeyboardKey.comma, control: true): () => _go(6),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: _go,
                labelType: NavigationRailLabelType.all,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Icon(
                    Icons.directions_railway,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                destinations: [
                  for (var i = 0; i < titles.length; i++)
                    NavigationRailDestination(
                      icon: Icon(_icons[i]),
                      selectedIcon: Icon(_icons[i], fill: 1),
                      label: Text(titles[i]),
                    ),
                ],
              ),
              VerticalDivider(thickness: 1, width: 1, color: Theme.of(context).dividerColor),
              Expanded(child: navigationShell),
            ],
          ),
        ),
      ),
    );
  }
}
