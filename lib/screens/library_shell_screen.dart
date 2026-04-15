import 'package:flutter/material.dart';

import '../core/layout/app_shell_layout.dart';
import '../features/discovery/presentation/screens/discovery_screen.dart';
import '../features/library/presentation/screens/library_hub_screen.dart';
import 'settings_screen.dart';

class LibraryShellScreen extends StatefulWidget {
  const LibraryShellScreen({super.key});

  @override
  State<LibraryShellScreen> createState() => _LibraryShellScreenState();
}

class _LibraryShellScreenState extends State<LibraryShellScreen> {
  int _index = 0;

  static const _railDestinations = <({
    Icon icon,
    Icon selectedIcon,
    String label,
  })>[
    (
      icon: Icon(Icons.auto_stories_outlined),
      selectedIcon: Icon(Icons.auto_stories_rounded),
      label: 'Library',
    ),
    (
      icon: Icon(Icons.explore_outlined),
      selectedIcon: Icon(Icons.explore_rounded),
      label: 'Discover',
    ),
    (
      icon: Icon(Icons.tune_rounded),
      selectedIcon: Icon(Icons.settings_rounded),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = const [
      LibraryHubScreen(),
      DiscoveryScreen(),
      SettingsScreen(),
    ];

    final useRail = useSideNavigationRail(context);
    final width = MediaQuery.sizeOf(context).width;
    final railExtended = width >= 1000;

    if (useRail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: railExtended,
              selectedIndex: _index,
              onDestinationSelected: (value) {
                setState(() {
                  _index = value;
                });
              },
              labelType: railExtended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              destinations: [
                for (final d in _railDestinations)
                  NavigationRailDestination(
                    icon: d.icon,
                    selectedIcon: d.selectedIcon,
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              child: IndexedStack(
                index: _index,
                children: pages,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() {
            _index = value;
          });
        },
        destinations: [
          for (final d in _railDestinations)
            NavigationDestination(
              icon: d.icon,
              selectedIcon: d.selectedIcon,
              label: d.label,
            ),
        ],
      ),
    );
  }
}
