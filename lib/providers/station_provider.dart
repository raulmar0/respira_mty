import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/station.dart';
import '../services/air_quality_service.dart';
import 'location_provider.dart';

enum StationsListFilter { all, favorites, nearest }

class FavoriteStationsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void toggle(String stationId) {
    final updated = <String>{...state};
    if (!updated.remove(stationId)) {
      updated.add(stationId);
    }
    state = updated;
  }
}

class StationSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

class StationsListFilterNotifier extends Notifier<StationsListFilter> {
  @override
  StationsListFilter build() => StationsListFilter.all;

  void setFilter(StationsListFilter value) => state = value;
}

final airQualityProvider = FutureProvider<List<Station>>((ref) {
  final service = AirQualityService();
  return service.fetchStations();
});

final favoriteStationsProvider =
    NotifierProvider<FavoriteStationsNotifier, Set<String>>(
      FavoriteStationsNotifier.new,
    );

final stationSearchQueryProvider =
    NotifierProvider<StationSearchQueryNotifier, String>(
      StationSearchQueryNotifier.new,
    );

final stationsListFilterProvider =
    NotifierProvider<StationsListFilterNotifier, StationsListFilter>(
      StationsListFilterNotifier.new,
    );

final filteredStationsProvider = Provider<AsyncValue<List<Station>>>((ref) {
  final stationsAsync = ref.watch(airQualityProvider);
  final locationAsync = ref.watch(currentLocationProvider);
  final favorites = ref.watch(favoriteStationsProvider);
  final query = ref.watch(stationSearchQueryProvider).trim().toLowerCase();
  final filter = ref.watch(stationsListFilterProvider);

  return stationsAsync.whenData((stations) {
    List<Station> result = List<Station>.from(stations);

    if (filter == StationsListFilter.favorites) {
      result = result.where((s) => favorites.contains(s.id)).toList();
    }

    if (query.isNotEmpty) {
      result = result.where((s) {
        final name = s.name.toLowerCase();
        final apiCode = s.apiCode.toLowerCase();
        return name.contains(query) || apiCode.contains(query);
      }).toList();
    }

    if (filter == StationsListFilter.nearest) {
      // Use device location if available, otherwise fallback to Monterrey center
      final deviceCenter = locationAsync.maybeWhen(
        data: (latlng) => latlng,
        orElse: () => null,
      );
      final centerLat = deviceCenter?.latitude ?? 25.6866;
      final centerLng = deviceCenter?.longitude ?? -100.3161;
      double haversineDistance(Station a) {
        const earthRadius = 6371.0; // km
        final lat1 = centerLat * (math.pi / 180);
        final lon1 = centerLng * (math.pi / 180);
        final lat2 = a.latitude * (math.pi / 180);
        final lon2 = a.longitude * (math.pi / 180);

        final dLat = lat2 - lat1;
        final dLon = lon2 - lon1;

        final hav = math.pow(math.sin(dLat / 2), 2) +
            math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dLon / 2), 2);
        final c = 2 * math.asin(math.sqrt(hav));
        return earthRadius * c;
      }

      result.sort((a, b) => haversineDistance(a).compareTo(haversineDistance(b)));
    }

    return List<Station>.unmodifiable(result);
  });
});

final lastUpdateProvider = Provider<DateTime?>((ref) {
  final stationsAsync = ref.watch(airQualityProvider);
  return stationsAsync.when(
    data: (stations) {
      final dates = stations.map((s) => s.updatedAt).whereType<DateTime>().toList();
      if (dates.isEmpty) return null;
      dates.sort((a, b) => b.compareTo(a)); // newest first
      return dates.first;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
