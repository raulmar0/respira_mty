import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../data/station_locations.dart';
import '../models/station.dart';
import '../providers/station_provider.dart';
import '../widgets/station_card.dart';
import '../utils/app_colors.dart';
import '../utils/air_quality_scale.dart';
import 'package:respira_mty/l10n/app_localizations.dart';

class StationsMapScreen extends ConsumerStatefulWidget {
  const StationsMapScreen({super.key});

  @override
  ConsumerState<StationsMapScreen> createState() => _StationsMapScreenState();
}

enum _StationFilter { all, good, moderate, unhealthy }

class _StationsMapScreenState extends ConsumerState<StationsMapScreen> with AutomaticKeepAliveClientMixin<StationsMapScreen> {
  Station? _selectedStation;
  _StationFilter _activeFilter = _StationFilter.all;
  final MapController _mapController = MapController();

  @override
  bool get wantKeepAlive => true;


  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final iconColor = theme.iconTheme.color ?? (isDark ? Colors.white : Colors.black87);
    final headerBg = cardColor;
    final headerTextColor = theme.textTheme.titleLarge?.color ?? (isDark ? Colors.white : Colors.black87);
    final headerShadowAlpha = isDark ? 0.6 : 0.1;
    final stationsAsync = ref.watch(airQualityProvider);
    final favoriteIds = ref.watch(favoriteStationsProvider);
    final stationLocationAccent = theme.colorScheme.primary;
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

    // Apply selected filter to stations shown on the map
    final displayedStations = stationMarkers.where((station) {
      switch (_activeFilter) {
        case _StationFilter.all:
          return true;
        case _StationFilter.good:
          return station.dominantPollutant.category == AirQualityCategory.good;
        case _StationFilter.moderate:
          return station.dominantPollutant.category == AirQualityCategory.acceptable;
        case _StationFilter.unhealthy:
          final cat = station.dominantPollutant.category;
          return cat == AirQualityCategory.bad || cat == AirQualityCategory.veryBad || cat == AirQualityCategory.extremelyBad;
      }
    }).toList();

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
                        color: theme.cardTheme.color ?? theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: stationLocationAccent,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withValues(alpha: 0.15),
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
                markers: displayedStations.map((station) {
                  final dominant = station.dominantPollutant;
                  final color = dominant.color;
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
                          color: theme.cardTheme.color ?? theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withValues(alpha: 0.20),
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
                        AppLocalizations.of(context)!.errorLoadingAirQuality,
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
                          color: headerBg,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withValues(alpha: headerShadowAlpha),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.stationsMapTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: headerTextColor,
                          ),
                        ),
                      ),
                      const SizedBox.shrink(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                              _buildFilterChip(
                          AppLocalizations.of(context)!.filterAll,
                          filter: _StationFilter.all,
                          isSelected: _activeFilter == _StationFilter.all,
                          onTap: () {
                            setState(() {
                              _activeFilter = _StationFilter.all;
                              _selectedStation = null;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.filterGood,
                          filter: _StationFilter.good,
                          isSelected: _activeFilter == _StationFilter.good,
                          onTap: () {
                            setState(() {
                              _activeFilter = _StationFilter.good;
                              _selectedStation = null;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.filterModerate,
                          filter: _StationFilter.moderate,
                          isSelected: _activeFilter == _StationFilter.moderate,
                          onTap: () {
                            setState(() {
                              _activeFilter = _StationFilter.moderate;
                              _selectedStation = null;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          AppLocalizations.of(context)!.filterUnhealthy,
                          filter: _StationFilter.unhealthy,
                          isSelected: _activeFilter == _StationFilter.unhealthy,
                          onTap: () {
                            setState(() {
                              _activeFilter = _StationFilter.unhealthy;
                              _selectedStation = null;
                            });
                          },
                        ),
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
                _buildMapControl(
                  Icons.add,
                  () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    );
                  },
                  backgroundColor: cardColor,
                  iconColorParam: iconColor,
                ),
                const SizedBox(height: 8),
                _buildMapControl(
                  Icons.remove,
                  () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    );
                  },
                  backgroundColor: cardColor,
                  iconColorParam: iconColor,
                ),
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

    );
  }

  Widget _buildFilterChip(String label, {required _StationFilter filter, bool isSelected = false, VoidCallback? onTap}) {
    // Map filter enum to global status colors (language independent)
    late final StatusColors statusColors;

    switch (filter) {
      case _StationFilter.all:
        statusColors = AppColors.getColorsForStatus(Status.fueraDeServicio);
        break;
      case _StationFilter.good:
        statusColors = AppColors.getColorsForStatus(Status.good);
        break;
      case _StationFilter.moderate:
        statusColors = AppColors.getColorsForStatus(Status.moderate);
        break;
      case _StationFilter.unhealthy:
        statusColors = AppColors.getColorsForStatus(Status.unhealthy);
        break;
    }

    final Color backgroundColor = isSelected ? const Color(0xFF1A1F36) : statusColors.background;

    final Color textColor = isSelected ? Colors.white : statusColors.text;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
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
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMapControl(IconData icon, VoidCallback onTap, {Color? backgroundColor, Color? iconColorParam}) {
    final bg = backgroundColor ?? Colors.white;
    final ic = iconColorParam ?? Colors.black87;
    final shadowColor = Theme.of(context).shadowColor.withValues(alpha: 0.1);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: ic, size: 24),
      ),
    );
  }
}
