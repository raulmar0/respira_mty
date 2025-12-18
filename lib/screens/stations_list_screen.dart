import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/station_provider.dart';
import '../widgets/station_card.dart';

import 'stations_map_screen.dart';

class StationsListScreen extends ConsumerStatefulWidget {
  const StationsListScreen({super.key});

  @override
  ConsumerState<StationsListScreen> createState() => _StationsListScreenState();
}

class _StationsListScreenState extends ConsumerState<StationsListScreen> {
  bool _showSearch = false;

  @override
  Widget build(BuildContext context) {
    final stationsAsync = ref.watch(filteredStationsProvider);
    final favorites = ref.watch(favoriteStationsProvider);
    final selectedFilter = ref.watch(stationsListFilterProvider);
    final query = ref.watch(stationSearchQueryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Estaciones',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        _showSearch ? Icons.close : Icons.search,
                        color: const Color(0xFF1A1F36),
                      ),
                      onPressed: () {
                        setState(() {
                          _showSearch = !_showSearch;
                        });
                        if (!_showSearch) {
                          ref
                              .read(stationSearchQueryProvider.notifier)
                              .setQuery('');
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (_showSearch) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Buscar estación…',
                      suffixIcon: query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                ref
                                    .read(stationSearchQueryProvider.notifier)
                                    .setQuery('');
                              },
                            ),
                    ),
                    onChanged: (value) {
                      ref
                          .read(stationSearchQueryProvider.notifier)
                          .setQuery(value);
                    },
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'MONTERREY • LAST UPDATED: 10:30 AM',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      'All Stations',
                      isSelected: selectedFilter == StationsListFilter.all,
                      onTap: () => ref
                          .read(stationsListFilterProvider.notifier)
                          .setFilter(StationsListFilter.all),
                    ),
                    const SizedBox(width: 12),
                    _buildFilterChip(
                      'Favorites',
                      isSelected:
                          selectedFilter == StationsListFilter.favorites,
                      onTap: () => ref
                          .read(stationsListFilterProvider.notifier)
                          .setFilter(StationsListFilter.favorites),
                    ),
                    const SizedBox(width: 12),
                    _buildFilterChip('Nearest'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: stationsAsync.when(
                  data: (stations) => ListView.builder(
                    itemCount: stations.length,
                    itemBuilder: (context, index) {
                      final station = stations[index];
                      final isFavorite = favorites.contains(station.id);
                      return StationCard(
                        station: station,
                        isFavorite: isFavorite,
                        onFavoriteToggle: () {
                          ref
                              .read(favoriteStationsProvider.notifier)
                              .toggle(station.id);
                        },
                      );
                    },
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text(
                      'No se pudieron cargar las estaciones',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey[400],
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StationsMapScreen(),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
        currentIndex: 1,
      ),
    );
  }

  Widget _buildFilterChip(
    String label, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A1F36) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1A1F36).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
