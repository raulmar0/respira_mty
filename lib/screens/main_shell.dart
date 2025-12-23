import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF5CE57E),
        unselectedItemColor: Colors.grey,
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildTabNavigator(GlobalKey<NavigatorState> key, Widget child) {
    return Navigator(
      key: key,
      onGenerateRoute: (settings) => MaterialPageRoute(builder: (_) => child),
    );
  }
}
