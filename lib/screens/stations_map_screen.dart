import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../data/station_locations.dart';
import '../models/station.dart';
import '../providers/station_provider.dart';
import '../utils/air_quality_scale.dart';
import '../widgets/station_card.dart';

class StationsMapScreen extends ConsumerStatefulWidget {
  const StationsMapScreen({super.key});

  @override
  ConsumerState<StationsMapScreen> createState() => _StationsMapScreenState();
}

class _StationsMapScreenState extends ConsumerState<StationsMapScreen> {
  Station? _selectedStation;
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final stationsAsync = ref.watch(airQualityProvider);
    final favoriteIds = ref.watch(favoriteStationsProvider);
    const stationLocationAccent = Color(0xFF1A73E8);
    final stationMarkers = stationsAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const [],
    );
    Station? selectedStation;
    if (_selectedStation != null) {
      for (final station in stationMarkers) {
        if (station.id == _selectedStation!.id) {
          selectedStation = station;
          break;
        }
      }
    }
    final stationToShow = selectedStation;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(
                25.6866,
                -100.3161,
              ), // Monterrey Center
              initialZoom: 11.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedStation = null;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.respira_mty',
              ),
              MarkerLayer(
                markers: stationLocations.map((location) {
                  return Marker(
                    point: location.coords,
                    width: 36,
                    height: 36,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: stationLocationAccent,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.location_on,
                          size: 16,
                          color: stationLocationAccent,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              MarkerLayer(
                markers: stationMarkers.map((station) {
                  final dominant = station.dominantPollutant;
                  final color = dominant.color;
                  final outerColor = AirQualityScale.getBackgroundColorForCategory(dominant.category);
                  return Marker(
                    point: LatLng(station.latitude, station.longitude),
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedStation = station;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: outerColor, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.air, size: 16, color: color),
                              Text(
                                dominant.displayValue,
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          if (stationsAsync.isLoading)
            const Positioned(
              bottom: 200,
              left: 0,
              right: 0,
              child: Center(child: CircularProgressIndicator()),
            ),
          if (stationsAsync.hasError)
            Positioned(
              top: 200,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No se pudo cargar la calidad del aire. Revisa tu conexión.',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Mapa de Estaciones',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.layers_outlined,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All Stations', isSelected: true),
                        const SizedBox(width: 8),
                        _buildFilterChip('Good'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Moderate'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Unhealthy'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: _selectedStation != null ? 280 : 100,
            child: Column(
              children: [
                _buildMapControl(Icons.my_location, () {}),
                const SizedBox(height: 16),
                _buildMapControl(Icons.add, () {
                  _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom + 1,
                  );
                }),
                const SizedBox(height: 8),
                _buildMapControl(Icons.remove, () {
                  _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom - 1,
                  );
                }),
              ],
            ),
          ),
          if (stationToShow != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: StationCard(
                station: stationToShow,
                isFavorite: favoriteIds.contains(stationToShow.id),
                onFavoriteToggle: () => ref
                    .read(favoriteStationsProvider.notifier)
                    .toggle(stationToShow.id),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey[400],
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: 0, // Map is selected
        onTap: (index) {
          if (index == 1) {
            Navigator.pop(context); // Go back to list
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
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1A1F36) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : const Color(0xFFD35400), // Orange-ish for unselected in image
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMapControl(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black87, size: 24),
      ),
    );
  }
}
