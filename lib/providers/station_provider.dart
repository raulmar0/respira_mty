import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/station.dart';
import '../services/air_quality_service.dart';
import 'location_provider.dart';

enum StationsListFilter { all, favorites, nearest }

/// Persists the user's favorite station ids across app restarts using
/// `SharedPreferences`. Mirrors the load-on-build / save-on-change pattern
/// used by `LanguageNotifier` so the UI stays responsive — the empty default
/// is returned synchronously and the saved value replaces it once the prefs
/// finish loading.
class FavoriteStationsNotifier extends Notifier<Set<String>> {
  static const String _key = 'favorite_stations';

  @override
  Set<String> build() {
    _loadSaved();
    return <String>{};
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key);
    if (saved != null && saved.isNotEmpty) {
      state = saved.toSet();
    }
  }

  Future<void> _persist(Set<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, value.toList());
  }

  void toggle(String stationId) {
    final updated = <String>{...state};
    if (!updated.remove(stationId)) {
      updated.add(stationId);
    }
    state = updated;
    // Persist asynchronously; don't block the UI. Errors are swallowed so a
    // transient prefs failure doesn't crash the app — worst case the favorite
    // is lost on next launch.
    _persist(updated);
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

/// Human-readable loading caption emitted while [AirQualityService] fetches
/// stations one by one. Consumed by the UI to show "Cargando La Pastora (3/17)".
class LoadingMessageNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
}

final loadingMessageProvider =
    NotifierProvider<LoadingMessageNotifier, String?>(
  LoadingMessageNotifier.new,
);

class AirQualityNotifier extends AsyncNotifier<List<Station>> {
  @override
  Future<List<Station>> build() async {
    final service = AirQualityService();
    try {
      return await service.fetchStations(
        useCache: true,
        forceRefresh: false,
        onProgress: _emitProgress,
      );
    } finally {
      ref.read(loadingMessageProvider.notifier).state = null;
    }
  }

  /// Forces a network refresh and updates the cache.
  /// Throws if the network call fails so callers can show error UI.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = AirQualityService();
      return service.fetchStations(
        useCache: false,
        forceRefresh: true,
        onProgress: _emitProgress,
      );
    });
    ref.read(loadingMessageProvider.notifier).state = null;
    if (state.hasError) throw state.error!;
  }

  void _emitProgress(String name, int current, int total) {
    ref.read(loadingMessageProvider.notifier).state =
        'Cargando $name ($current/$total)';
  }
}

final airQualityProvider =
    AsyncNotifierProvider<AirQualityNotifier, List<Station>>(
  AirQualityNotifier.new,
);

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

/// Sorting options for the stations list
enum StationsSort { plusQuality, minusQuality, az, za }

class StationsSortNotifier extends Notifier<StationsSort> {
  @override
  StationsSort build() => StationsSort.plusQuality;

  void set(StationsSort s) => state = s;
}

final stationsSortProvider = NotifierProvider<StationsSortNotifier, StationsSort>(
  StationsSortNotifier.new,
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

    // Apply sorting option if not 'nearest' (nearest already sorts by distance)
    final sort = ref.watch(stationsSortProvider);
    if (filter != StationsListFilter.nearest) {
      switch (sort) {
        case StationsSort.plusQuality:
          // Lowest AQI (best quality) first
          result.sort((a, b) => a.aqi.compareTo(b.aqi));
          break;
        case StationsSort.minusQuality:
          // Highest AQI (worst quality) first
          result.sort((a, b) => b.aqi.compareTo(a.aqi));
          break;
        case StationsSort.az:
          result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          break;
        case StationsSort.za:
          result.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
          break;
      }
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
    error: (error, stack) => null,
  );
});
