import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:respira_mty/l10n/app_localizations.dart';
import '../providers/navigation_provider.dart';
import 'stations_map_screen.dart';
import 'stations_list_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(4, (_) => GlobalKey<NavigatorState>());

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: [
          _buildTabNavigator(_navigatorKeys[0], const StationsMapScreen()),
          _buildTabNavigator(_navigatorKeys[1], const StationsListScreen()),
          _buildTabNavigator(_navigatorKeys[2], const NotificationsScreen()),
          _buildTabNavigator(_navigatorKeys[3], const SettingsScreen()),
        ],
      ),
      bottomNavigationBar: Builder(builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final selectedColor = isDark ? Colors.white : Colors.black87;
        final baseIconColor = theme.colorScheme.onSurface;
        final unselectedColor = baseIconColor.withValues(alpha: 0.6);
        final backgroundColor = isDark ? const Color.fromARGB(255, 22, 23, 24) : theme.colorScheme.surface;

        final itemData = [
          {'icon': Icons.map_outlined, 'label': AppLocalizations.of(context)!.stationsMapTitle},
          {'icon': Icons.list, 'label': AppLocalizations.of(context)!.stationsTitle},
          {'icon': Icons.notifications_outlined, 'label': AppLocalizations.of(context)!.notificationsTitle},
          {'icon': Icons.settings_outlined, 'label': AppLocalizations.of(context)!.settingsTitle},
        ];

        return BottomNavigationBar(
          currentIndex: selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: backgroundColor,
          selectedItemColor: selectedColor,
          unselectedItemColor: unselectedColor,
          showUnselectedLabels: true,
          onTap: (index) {
            final currentIndex = ref.read(selectedTabProvider);

          // If tapping the current tab, pop its navigator to root
          if (index == currentIndex) {
            _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
            return;
          }

          // Otherwise switch tab
          ref.read(selectedTabProvider.notifier).setIndex(index);

          // If switching to List, ensure the List tab is at its root
          if (index == 1) {
            _navigatorKeys[1].currentState?.popUntil((route) => route.isFirst);
          }
        },
        items: itemData.map((data) => BottomNavigationBarItem(
          icon: Padding(padding: EdgeInsets.only(top: 6), child: Icon(data['icon'] as IconData)),
          label: data['label'] as String,
        )).toList(),
      );
    }),
    );
  }

  Widget _buildTabNavigator(GlobalKey<NavigatorState> key, Widget child) {
    return Navigator(
      key: key,
      onGenerateRoute: (settings) => MaterialPageRoute(builder: (_) => child),
    );
  }
}
