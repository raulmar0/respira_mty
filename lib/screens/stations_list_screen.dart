import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/station_provider.dart';
import '../providers/location_provider.dart';
import 'package:geolocator/geolocator.dart';
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
                  Row(
                    children: [
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
                          tooltip: 'Refresh location',
                          icon: const Icon(Icons.my_location),
                          color: const Color(0xFF1A1F36),
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Comprobando permisos de ubicación...')),
                            );

                            final serviceEnabled = await Geolocator.isLocationServiceEnabled();
                            if (!serviceEnabled) {
                              messenger.showSnackBar(
                                const SnackBar(content: Text('El servicio de ubicación está desactivado en el dispositivo. Actívalo en ajustes o en el emulador.')),
                              );
                              debugPrint('Location service disabled');
                              return;
                            }

                            LocationPermission permission = await Geolocator.checkPermission();
                            if (permission == LocationPermission.denied) {
                              permission = await Geolocator.requestPermission();
                            }

                            if (permission == LocationPermission.denied) {
                              messenger.showSnackBar(
                                const SnackBar(content: Text('Permiso denegado. Concede permiso de ubicación a la app.')),
                              );
                              debugPrint('Location permission denied');
                              return;
                            }

                            if (permission == LocationPermission.deniedForever) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: const Text('Permiso denegado permanentemente. Abre ajustes para permitir la ubicación.'),
                                  action: SnackBarAction(
                                    label: 'Abrir ajustes',
                                    onPressed: () => Geolocator.openAppSettings(),
                                  ),
                                ),
                              );
                              debugPrint('Location permission denied forever');
                              return;
                            }

                            messenger.showSnackBar(
                              const SnackBar(content: Text('Obteniendo ubicación...')),
                            );

                            try {
                              final latlng = await ref.refresh(currentLocationProvider.future);
                              if (latlng == null) {
                                messenger.showSnackBar(
                                  const SnackBar(content: Text('No se obtuvo ubicación (error).')),
                                );
                                debugPrint('currentLocationProvider returned null');
                              } else {
                                messenger.showSnackBar(
                                  SnackBar(content: Text('Ubicación: ${latlng.latitude}, ${latlng.longitude}')),
                                );
                                debugPrint('Device location: ${latlng.latitude}, ${latlng.longitude}');
                              }
                            } catch (e, st) {
                              messenger.showSnackBar(
                                SnackBar(content: Text('Error obteniendo ubicación: $e')),
                              );
                              debugPrint('Error getting location: $e');
                              debugPrintStack(stackTrace: st);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
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
                    _buildFilterChip(
                      'Nearest',
                      isSelected: selectedFilter == StationsListFilter.nearest,
                      onTap: () => ref
                          .read(stationsListFilterProvider.notifier)
                          .setFilter(StationsListFilter.nearest),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: selectedFilter == StationsListFilter.favorites && favorites.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite_border, size: 56, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              'No hay favoritos seleccionados',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Marca estaciones con el corazón para verlas aquí.',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : stationsAsync.when(
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
                        loading: () => ListView.builder(
                          itemCount: 4,
                          padding: const EdgeInsets.only(top: 0, bottom: 16),
                          itemBuilder: (context, index) => const StationCardSkeleton(),
                        ),
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
