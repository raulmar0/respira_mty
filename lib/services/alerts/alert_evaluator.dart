import 'package:latlong2/latlong.dart';
import 'package:respira_mty/models/alert_event.dart';
import 'package:respira_mty/models/alert_preferences.dart';
import 'package:respira_mty/models/alert_rule.dart';
import 'package:respira_mty/models/station.dart';
import 'package:respira_mty/utils/air_quality_scale.dart';

/// Pure function: turns the current state of stations + history + prefs into
/// a list of [AlertRule]s to fire. No I/O, no platform calls.
class AlertEvaluator {
  /// Evaluates the alert engine and returns the rules that should fire.
  ///
  /// First-run behavior: if [lastSeenByStation] is empty, returns []. The
  /// caller must seed the baseline from current categories. This prevents
  /// bombardment when the user enables alerts on already-bad stations.
  ///
  /// Quiet hours: when [prefs.quietHours.enabled] is true and [now]
  /// (interpreted as local time) is within the window, no rules are emitted.
  /// Window may cross midnight.
  ///
  /// Cooldown: a station that fired within prefs.cooldownHours ago does not
  /// re-fire UNLESS the new category index is strictly greater than the last
  /// fired event's category (worsening override).
  List<AlertRule> evaluate({
    required List<Station> stations,
    required AlertPreferences prefs,
    required Map<String, AirQualityCategory> lastSeenByStation,
    required List<AlertEvent> recentHistory,
    required Set<String> favorites,
    required DateTime now,
    LatLng? userLocation,
  }) {
    if (!prefs.enabled) return const <AlertRule>[];
    if (isInQuietHours(prefs.quietHours, now)) return const <AlertRule>[];

    // First-run baseline guard: caller must seed before the evaluator can
    // actually fire anything. Prevents day-1 alert bombardment.
    if (lastSeenByStation.isEmpty) return const <AlertRule>[];

    final scoped = _scope(stations, prefs, favorites, userLocation);
    final output = <AlertRule>[];

    for (final s in scoped) {
      final dom = s.dominantPollutant;

      // Skip stations with no data.
      if (dom.category == AirQualityCategory.maintenance) continue;

      // Skip muted pollutants.
      if (prefs.mutedPollutants.contains(dom.name)) continue;

      final prev = lastSeenByStation[s.id];

      // Below-threshold path. Only emits an improvement event when opted-in.
      if (dom.category.index < prefs.threshold.index) {
        if (prev != null &&
            prev.index >= prefs.threshold.index &&
            dom.category == AirQualityCategory.good &&
            prefs.notifyOnImprovement) {
          output.add(
            AlertRule(
              stationId: s.id,
              stationName: s.name,
              category: dom.category,
              previousCategory: prev,
              dominantPollutant: dom.name,
              value: dom.value,
              unit: dom.unit,
              reason: AlertReason.improvementBackToGood,
            ),
          );
        }
        continue;
      }

      // At/above threshold. Apply cooldown + worsening override.
      final lastFire = _latestFireForStation(recentHistory, s.id);
      if (lastFire != null) {
        final sameOrLowerCategory = dom.category.index <= lastFire.category.index;
        final withinCooldown = now.difference(lastFire.firedAt) <
            Duration(hours: prefs.cooldownHours);
        if (withinCooldown && sameOrLowerCategory) continue;
        // Worsening within cooldown: allow.
      }

      final reason = (prev != null && dom.category.index > prev.index)
          ? AlertReason.worseningCategory
          : AlertReason.crossingThreshold;

      output.add(
        AlertRule(
          stationId: s.id,
          stationName: s.name,
          category: dom.category,
          previousCategory: prev,
          dominantPollutant: dom.name,
          value: dom.value,
          unit: dom.unit,
          reason: reason,
        ),
      );
    }

    return output;
  }

  /// Public for testability.
  bool isInQuietHours(QuietHours qh, DateTime now) {
    if (!qh.enabled) return false;
    final localNow = now.toLocal();
    final mod = localNow.hour * 60 + localNow.minute;
    if (qh.startMinute == qh.endMinute) return false; // zero-length window
    if (qh.startMinute < qh.endMinute) {
      return mod >= qh.startMinute && mod < qh.endMinute;
    }
    // Window crosses midnight.
    return mod >= qh.startMinute || mod < qh.endMinute;
  }

  // ---- internals ---------------------------------------------------------

  List<Station> _scope(
    List<Station> stations,
    AlertPreferences prefs,
    Set<String> favorites,
    LatLng? userLocation,
  ) {
    switch (prefs.scope) {
      case AlertScope.all:
        return stations;
      case AlertScope.favorites:
        return stations.where((s) => favorites.contains(s.id)).toList();
      case AlertScope.nearest:
        if (stations.isEmpty) return const <Station>[];
        if (userLocation != null) {
          const distance = Distance();
          // Sort by distance ascending.
          final sorted = [...stations]
            ..sort((a, b) {
              final da = distance.as(
                LengthUnit.Kilometer,
                userLocation,
                LatLng(a.latitude, a.longitude),
              );
              final db = distance.as(
                LengthUnit.Kilometer,
                userLocation,
                LatLng(b.latitude, b.longitude),
              );
              return da.compareTo(db);
            });
          final radius = prefs.nearestRadiusKm.toDouble();
          final within = sorted.where((s) {
            final d = distance.as(
              LengthUnit.Kilometer,
              userLocation,
              LatLng(s.latitude, s.longitude),
            );
            return d <= radius;
          }).toList();
          if (within.isNotEmpty) return within;
          // No station within radius — fall back to the closest one.
          return [sorted.first];
        }
        // No userLocation — fall back to the single worst-category station.
        return _pickWorstCategory(stations);
    }
  }

  /// Returns the single station with the worst (highest-index) air-quality
  /// category, excluding maintenance stations. Maintenance has the highest
  /// enum index but represents missing data, not severity — including it
  /// would suppress real alerts (the evaluator skips maintenance stations
  /// downstream). Returns an empty list if no non-maintenance candidates
  /// remain.
  List<Station> _pickWorstCategory(List<Station> stations) {
    final candidates = stations
        .where((s) =>
            s.dominantPollutant.category != AirQualityCategory.maintenance)
        .toList();
    if (candidates.isEmpty) return const <Station>[];
    candidates.sort((a, b) {
      return b.dominantPollutant.category.index
          .compareTo(a.dominantPollutant.category.index);
    });
    return [candidates.first];
  }

  AlertEvent? _latestFireForStation(List<AlertEvent> history, String stationId) {
    AlertEvent? latest;
    for (final h in history) {
      if (h.stationId != stationId) continue;
      if (latest == null || h.firedAt.isAfter(latest.firedAt)) {
        latest = h;
      }
    }
    return latest;
  }
}
