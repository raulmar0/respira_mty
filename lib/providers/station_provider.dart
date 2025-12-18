import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/station.dart';
import '../services/air_quality_service.dart';

enum StationsListFilter { all, favorites }

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
  final favorites = ref.watch(favoriteStationsProvider);
  final query = ref.watch(stationSearchQueryProvider).trim().toLowerCase();
  final filter = ref.watch(stationsListFilterProvider);

  return stationsAsync.whenData((stations) {
    Iterable<Station> result = stations;

    if (filter == StationsListFilter.favorites) {
      result = result.where((s) => favorites.contains(s.id));
    }

    if (query.isNotEmpty) {
      result = result.where((s) {
        final name = s.name.toLowerCase();
        final apiCode = s.apiCode.toLowerCase();
        return name.contains(query) || apiCode.contains(query);
      });
    }

    return result.toList(growable: false);
  });
});
