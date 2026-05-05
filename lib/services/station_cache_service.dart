import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/station.dart';

/// Caches the last successful [fetchStations] result with a TTL so the UI
/// opens instantly and background tasks skip redundant API calls.
///
/// The cache key is versioned (`v1`) so schema changes can invalidate old
/// entries automatically.
class StationCacheService {
  static const String _key = 'station_cache_v1';
  static const String _timestampKey = 'station_cache_timestamp_v1';

  /// Default TTL. 20 minutes matches the user's observation that SIMA data
  /// doesn't change faster than that.
  static const Duration defaultTtl = Duration(minutes: 20);

  /// Returns the cached stations if they exist and are younger than [ttl].
  /// Returns `null` if there is no cache or it has expired.
  Future<List<Station>?> load({Duration ttl = defaultTtl}) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(_key);
      final tsRaw = sp.getInt(_timestampKey);

      if (raw == null || raw.isEmpty || tsRaw == null) return null;

      final cachedAt = DateTime.fromMillisecondsSinceEpoch(tsRaw, isUtc: true);
      final age = DateTime.now().toUtc().difference(cachedAt);
      if (age > ttl) return null;

      final decoded = jsonDecode(raw) as List<dynamic>;
      final stations = decoded
          .map((json) => Station.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint(
        'StationCacheService: served ${stations.length} stations from cache '
        '(age: ${age.inMinutes}m)',
      );
      return stations;
    } catch (e, st) {
      debugPrint('StationCacheService load error: $e\n$st');
      return null;
    }
  }

  /// Persists [stations] and updates the timestamp to now.
  Future<void> save(List<Station> stations) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final encoded = jsonEncode(stations.map((s) => s.toJson()).toList());
      await sp.setString(_key, encoded);
      await sp.setInt(
        _timestampKey,
        DateTime.now().toUtc().millisecondsSinceEpoch,
      );
      debugPrint('StationCacheService: saved ${stations.length} stations');
    } catch (e, st) {
      debugPrint('StationCacheService save error: $e\n$st');
    }
  }

  /// Clears the cache. Useful for "pull to refresh" or logout flows.
  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key);
    await sp.remove(_timestampKey);
  }
}
