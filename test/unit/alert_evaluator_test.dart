import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:respira_mty/models/alert_event.dart';
import 'package:respira_mty/models/alert_preferences.dart';
import 'package:respira_mty/models/station.dart';
import 'package:respira_mty/services/alerts/alert_evaluator.dart';
import 'package:respira_mty/utils/air_quality_scale.dart';

/// Build a Station with a chosen dominant category by setting pm25 only.
/// PM2.5 thresholds: 15, 33, 79, 130 → categories good, acceptable, bad,
/// veryBad, extremelyBad respectively.
Station stationPm25({
  required String id,
  required String name,
  required double pm25,
  double lat = 25.67,
  double lng = -100.31,
}) => Station(
  id: id,
  apiCode: id.toUpperCase(),
  name: name,
  pm25: pm25,
  pm10: 1.0, // tiny so PM2.5 dominates
  o3: 1.0,
  no2: 1.0,
  so2: 1.0,
  co: 0.1,
  latitude: lat,
  longitude: lng,
);

/// Build a Station with O3 dominant (for muted-pollutant tests).
/// O3 thresholds: 58, 90, 135, 175.
Station stationO3({required String id, required double o3}) => Station(
  id: id,
  apiCode: id.toUpperCase(),
  name: id,
  o3: o3,
  latitude: 25.67,
  longitude: -100.31,
);

/// Maintenance station: no pollutant data — DominantPollutant comes back as
/// maintenance category.
Station stationNoData({required String id}) => Station(
  id: id,
  apiCode: id.toUpperCase(),
  name: id,
  latitude: 25.67,
  longitude: -100.31,
);

AlertEvent buildHistoryEvent({
  required String stationId,
  required AirQualityCategory category,
  required DateTime firedAt,
  String dominantPollutant = 'PM2.5',
  String id = 'h1',
}) => AlertEvent(
  id: id,
  stationId: stationId,
  stationName: 'X',
  category: category,
  dominantPollutant: dominantPollutant,
  dominantValue: 100,
  unit: 'µg/m³',
  firedAt: firedAt,
  localeAtFire: 'es',
  titleSnapshot: 't',
  bodySnapshot: 'b',
  read: false,
  reason: AlertReason.crossingThreshold,
);

AlertPreferences prefsWith({
  bool enabled = true,
  AirQualityCategory threshold = AirQualityCategory.veryBad,
  AlertScope scope = AlertScope.all,
  int nearestRadiusKm = 5,
  QuietHours? quietHours,
  Set<String> mutedPollutants = const <String>{},
  int cooldownHours = 6,
  bool notifyOnImprovement = false,
}) => AlertPreferences(
  enabled: enabled,
  threshold: threshold,
  scope: scope,
  nearestRadiusKm: nearestRadiusKm,
  quietHours: quietHours ?? const QuietHours.defaults(),
  mutedPollutants: mutedPollutants,
  cooldownHours: cooldownHours,
  notifyOnImprovement: notifyOnImprovement,
);

void main() {
  late AlertEvaluator evaluator;
  setUp(() {
    evaluator = AlertEvaluator();
  });

  group('AlertEvaluator', () {
    test('disabled prefs returns no rules', () {
      final s = stationPm25(id: 's1', name: 'S1', pm25: 200); // extremelyBad
      final out = evaluator.evaluate(
        stations: [s],
        prefs: prefsWith(enabled: false),
        lastSeenByStation: const {'s1': AirQualityCategory.good},
        recentHistory: const [],
        favorites: const {},
        now: DateTime.utc(2026, 4, 29, 14),
      );
      expect(out, isEmpty);
    });

    test('first-run with empty lastSeen returns no rules', () {
      final s = stationPm25(id: 's1', name: 'S1', pm25: 200);
      final out = evaluator.evaluate(
        stations: [s],
        prefs: prefsWith(),
        lastSeenByStation: const {},
        recentHistory: const [],
        favorites: const {},
        now: DateTime.utc(2026, 4, 29, 14),
      );
      expect(out, isEmpty);
    });

    test('quiet hours active suppresses rules', () {
      // Window enabled, 0..1440 → always-in
      final qh = const QuietHours(
        startMinute: 0,
        endMinute: 1440,
        enabled: true,
      );
      final s = stationPm25(id: 's1', name: 'S1', pm25: 200);
      final out = evaluator.evaluate(
        stations: [s],
        prefs: prefsWith(quietHours: qh),
        lastSeenByStation: const {'s1': AirQualityCategory.good},
        recentHistory: const [],
        favorites: const {},
        now: DateTime.utc(2026, 4, 29, 14),
      );
      expect(out, isEmpty);
    });

    test('quiet hours crossing midnight suppresses correctly', () {
      // 22:00 → 07:00
      const qh = QuietHours(startMinute: 22 * 60, endMinute: 7 * 60, enabled: true);
      final s = stationPm25(id: 's1', name: 'S1', pm25: 200);

      // 23:30 local → in window. Construct as local DateTime.
      final inWindow = DateTime(2026, 4, 29, 23, 30);
      final out1 = evaluator.evaluate(
        stations: [s],
        prefs: prefsWith(quietHours: qh),
        lastSeenByStation: const {'s1': AirQualityCategory.good},
        recentHistory: const [],
        favorites: const {},
        now: inWindow,
      );
      expect(out1, isEmpty);

      // 08:00 local → out of window
      final outWindow = DateTime(2026, 4, 29, 8, 0);
      final out2 = evaluator.evaluate(
        stations: [s],
        prefs: prefsWith(quietHours: qh),
        lastSeenByStation: const {'s1': AirQualityCategory.good},
        recentHistory: const [],
        favorites: const {},
        now: outWindow,
      );
      expect(out2.isNotEmpty, true);
    });

    test('below threshold returns no rules', () {
      // PM2.5 = 50 → bad. Threshold = veryBad → below.
      final s = stationPm25(id: 's1', name: 'S1', pm25: 50);
      final out = evaluator.evaluate(
        stations: [s],
        prefs: prefsWith(),
        lastSeenByStation: const {'s1': AirQualityCategory.good},
        recentHistory: const [],
        favorites: const {},
        now: DateTime.utc(2026, 4, 29, 14),
      );
      expect(out, isEmpty);
    });

    test('at/above threshold first time fires crossingThreshold', () {
      // pm25 = 200 → extremelyBad (above veryBad)
      final s = stationPm25(id: 's1', name: 'S1', pm25: 200);
      final out = evaluator.evaluate(
        stations: [s],
        prefs: prefsWith(),
        // baseline non-empty (other station seeded), but s1 not present
        lastSeenByStation: const {'other': AirQualityCategory.good},
        recentHistory: const [],
        favorites: const {},
        now: DateTime.utc(2026, 4, 29, 14),
      );
      expect(out.length, 1);
      expect(out.first.stationId, 's1');
      expect(out.first.category, AirQualityCategory.extremelyBad);
      expect(out.first.reason, AlertReason.crossingThreshold);
    });

    test('same category within cooldown is suppressed', () {
      final s = stationPm25(id: 's1', name: 'S1', pm25: 100); // veryBad
      final history = [
        buildHistoryEvent(
          stationId: 's1',
          category: AirQualityCategory.veryBad,
          firedAt: DateTime.utc(2026, 4, 29, 13),
        ),
      ];
      final out = evaluator.evaluate(
        stations: [s],
        prefs: prefsWith(cooldownHours: 6),
        lastSeenByStation: const {'s1': AirQualityCategory.veryBad},
        recentHistory: history,
        favorites: const {},
        now: DateTime.utc(2026, 4, 29, 14), // 1 hour later
      );
      expect(out, isEmpty);
    });

    test('worsening within cooldown fires worseningCategory', () {
      // Current: extremelyBad. Last fire was veryBad 1 hour ago.
      final s = stationPm25(id: 's1', name: 'S1', pm25: 200); // extremelyBad
      final history = [
        buildHistoryEvent(
          stationId: 's1',
          category: AirQualityCategory.veryBad,
          firedAt: DateTime.utc(2026, 4, 29, 13),
        ),
      ];
      final out = evaluator.evaluate(
        stations: [s],
        prefs: prefsWith(),
        lastSeenByStation: const {'s1': AirQualityCategory.veryBad},
        recentHistory: history,
        favorites: const {},
        now: DateTime.utc(2026, 4, 29, 14),
      );
      expect(out.length, 1);
      expect(out.first.reason, AlertReason.worseningCategory);
      expect(out.first.category, AirQualityCategory.extremelyBad);
      expect(out.first.previousCategory, AirQualityCategory.veryBad);
    });

    test('muted pollutant produces no rule', () {
      // O3 dominant, muted in prefs
      final s = stationO3(id: 's1', o3: 200); // extremelyBad
      final out = evaluator.evaluate(
        stations: [s],
        prefs: prefsWith(mutedPollutants: const {'O3'}),
        lastSeenByStation: const {'s1': AirQualityCategory.good},
        recentHistory: const [],
        favorites: const {},
        now: DateTime.utc(2026, 4, 29, 14),
      );
      expect(out, isEmpty);
    });

    test('maintenance category station never fires', () {
      final s = stationNoData(id: 's1');
      final out = evaluator.evaluate(
        stations: [s],
        prefs: prefsWith(),
        lastSeenByStation: const {'s1': AirQualityCategory.good},
        recentHistory: const [],
        favorites: const {},
        now: DateTime.utc(2026, 4, 29, 14),
      );
      expect(out, isEmpty);
    });

    test('scope=favorites filters non-favorite stations', () {
      final fav = stationPm25(id: 'fav', name: 'Fav', pm25: 200);
      final nonFav = stationPm25(id: 'nf', name: 'NF', pm25: 200);
      final out = evaluator.evaluate(
        stations: [fav, nonFav],
        prefs: prefsWith(scope: AlertScope.favorites),
        lastSeenByStation: const {
          'fav': AirQualityCategory.good,
          'nf': AirQualityCategory.good,
        },
        recentHistory: const [],
        favorites: const {'fav'},
        now: DateTime.utc(2026, 4, 29, 14),
      );
      expect(out.length, 1);
      expect(out.first.stationId, 'fav');
    });

    test('scope=nearest with userLocation filters by radius', () {
      // Reference user at (25.67, -100.31)
      // Close station at exactly that — distance ~0
      final close = stationPm25(
        id: 'close',
        name: 'Close',
        pm25: 200,
        lat: 25.67,
        lng: -100.31,
      );
      // Far station 100km north (~lat +0.9°)
      final far = stationPm25(
        id: 'far',
        name: 'Far',
        pm25: 200,
        lat: 26.57,
        lng: -100.31,
      );
      final out = evaluator.evaluate(
        stations: [close, far],
        prefs: prefsWith(scope: AlertScope.nearest, nearestRadiusKm: 5),
        lastSeenByStation: const {
          'close': AirQualityCategory.good,
          'far': AirQualityCategory.good,
        },
        recentHistory: const [],
        favorites: const {},
        now: DateTime.utc(2026, 4, 29, 14),
        userLocation: const LatLng(25.67, -100.31),
      );
      expect(out.length, 1);
      expect(out.first.stationId, 'close');
    });

    test('scope=nearest with null userLocation falls back to worst-category station', () {
      final s1 = stationPm25(id: 's1', name: 'S1', pm25: 50); // bad
      final s2 = stationPm25(id: 's2', name: 'S2', pm25: 200); // extremelyBad
      final s3 = stationPm25(id: 's3', name: 'S3', pm25: 100); // veryBad
      final out = evaluator.evaluate(
        stations: [s1, s2, s3],
        prefs: prefsWith(scope: AlertScope.nearest),
        lastSeenByStation: const {
          's1': AirQualityCategory.good,
          's2': AirQualityCategory.good,
          's3': AirQualityCategory.good,
        },
        recentHistory: const [],
        favorites: const {},
        now: DateTime.utc(2026, 4, 29, 14),
        userLocation: null,
      );
      expect(out.length, 1);
      expect(out.first.stationId, 's2');
    });

    test('scope=nearest with all stations beyond radius falls back to closest', () {
      // user at (25.67, -100.31)
      // a: ~10km north, b: ~50km north — neither within 5km radius
      final a = stationPm25(
        id: 'a',
        name: 'A',
        pm25: 200,
        lat: 25.76,
        lng: -100.31,
      );
      final b = stationPm25(
        id: 'b',
        name: 'B',
        pm25: 200,
        lat: 26.12,
        lng: -100.31,
      );
      final out = evaluator.evaluate(
        stations: [a, b],
        prefs: prefsWith(scope: AlertScope.nearest, nearestRadiusKm: 5),
        lastSeenByStation: const {
          'a': AirQualityCategory.good,
          'b': AirQualityCategory.good,
        },
        recentHistory: const [],
        favorites: const {},
        now: DateTime.utc(2026, 4, 29, 14),
        userLocation: const LatLng(25.67, -100.31),
      );
      expect(out.length, 1);
      expect(out.first.stationId, 'a');
    });

    test('improvement back to good when notifyOnImprovement=true', () {
      final s = stationPm25(id: 's1', name: 'S1', pm25: 5); // good
      final out = evaluator.evaluate(
        stations: [s],
        prefs: prefsWith(notifyOnImprovement: true),
        lastSeenByStation: const {'s1': AirQualityCategory.veryBad},
        recentHistory: const [],
        favorites: const {},
        now: DateTime.utc(2026, 4, 29, 14),
      );
      expect(out.length, 1);
      expect(out.first.reason, AlertReason.improvementBackToGood);
      expect(out.first.category, AirQualityCategory.good);
      expect(out.first.previousCategory, AirQualityCategory.veryBad);
    });

    test('improvement when notifyOnImprovement=false returns []', () {
      final s = stationPm25(id: 's1', name: 'S1', pm25: 5); // good
      final out = evaluator.evaluate(
        stations: [s],
        prefs: prefsWith(notifyOnImprovement: false),
        lastSeenByStation: const {'s1': AirQualityCategory.veryBad},
        recentHistory: const [],
        favorites: const {},
        now: DateTime.utc(2026, 4, 29, 14),
      );
      expect(out, isEmpty);
    });

    test('multiple stations: only above-threshold ones fire', () {
      final s1 = stationPm25(id: 's1', name: 'S1', pm25: 5); // good (below)
      final s2 = stationPm25(id: 's2', name: 'S2', pm25: 200); // extremelyBad
      final s3 = stationPm25(id: 's3', name: 'S3', pm25: 100); // veryBad
      final out = evaluator.evaluate(
        stations: [s1, s2, s3],
        prefs: prefsWith(),
        lastSeenByStation: const {
          's1': AirQualityCategory.good,
          's2': AirQualityCategory.good,
          's3': AirQualityCategory.good,
        },
        recentHistory: const [],
        favorites: const {},
        now: DateTime.utc(2026, 4, 29, 14),
      );
      final ids = out.map((r) => r.stationId).toSet();
      expect(ids, {'s2', 's3'});
    });

    test('cooldown boundary: just before end suppressed; at end allowed', () {
      final s = stationPm25(id: 's1', name: 'S1', pm25: 100); // veryBad
      final lastFire = DateTime.utc(2026, 4, 29, 8);
      final history = [
        buildHistoryEvent(
          stationId: 's1',
          category: AirQualityCategory.veryBad,
          firedAt: lastFire,
        ),
      ];

      // 1ms before cooldown ends (cooldown = 6h → 14:00 - 1ms)
      final justBefore = lastFire
          .add(const Duration(hours: 6))
          .subtract(const Duration(milliseconds: 1));
      final out1 = evaluator.evaluate(
        stations: [s],
        prefs: prefsWith(cooldownHours: 6),
        lastSeenByStation: const {'s1': AirQualityCategory.veryBad},
        recentHistory: history,
        favorites: const {},
        now: justBefore,
      );
      expect(out1, isEmpty, reason: 'within cooldown should suppress');

      // exactly at cooldown end
      final atEnd = lastFire.add(const Duration(hours: 6));
      final out2 = evaluator.evaluate(
        stations: [s],
        prefs: prefsWith(cooldownHours: 6),
        lastSeenByStation: const {'s1': AirQualityCategory.veryBad},
        recentHistory: history,
        favorites: const {},
        now: atEnd,
      );
      expect(out2.length, 1, reason: 'at cooldown end should allow new rule');
    });

    test('cooldown sameOrLowerCategory: lower category within cooldown suppressed', () {
      // Last fire was extremelyBad; current is veryBad (lower index).
      final s = stationPm25(id: 's1', name: 'S1', pm25: 100); // veryBad
      final history = [
        buildHistoryEvent(
          stationId: 's1',
          category: AirQualityCategory.extremelyBad,
          firedAt: DateTime.utc(2026, 4, 29, 13),
        ),
      ];
      final out = evaluator.evaluate(
        stations: [s],
        prefs: prefsWith(cooldownHours: 6),
        lastSeenByStation: const {'s1': AirQualityCategory.extremelyBad},
        recentHistory: history,
        favorites: const {},
        now: DateTime.utc(2026, 4, 29, 14),
      );
      expect(out, isEmpty);
    });
  });

  group('AlertEvaluator.isInQuietHours', () {
    test('disabled QH always returns false', () {
      const qh = QuietHours(startMinute: 0, endMinute: 1440, enabled: false);
      final ev = AlertEvaluator();
      expect(ev.isInQuietHours(qh, DateTime(2026, 4, 29, 12, 0)), false);
    });

    test('start==end is treated as zero-length window', () {
      const qh = QuietHours(startMinute: 600, endMinute: 600, enabled: true);
      final ev = AlertEvaluator();
      expect(ev.isInQuietHours(qh, DateTime(2026, 4, 29, 10, 0)), false);
    });

    test('same-day window: start<end', () {
      const qh = QuietHours(
        startMinute: 9 * 60,
        endMinute: 17 * 60,
        enabled: true,
      );
      final ev = AlertEvaluator();
      expect(ev.isInQuietHours(qh, DateTime(2026, 4, 29, 10)), true);
      expect(ev.isInQuietHours(qh, DateTime(2026, 4, 29, 17)), false);
      expect(ev.isInQuietHours(qh, DateTime(2026, 4, 29, 8, 59)), false);
      expect(ev.isInQuietHours(qh, DateTime(2026, 4, 29, 16, 59)), true);
    });

    test('crossing-midnight window: start>end', () {
      const qh = QuietHours(
        startMinute: 22 * 60,
        endMinute: 7 * 60,
        enabled: true,
      );
      final ev = AlertEvaluator();
      expect(ev.isInQuietHours(qh, DateTime(2026, 4, 29, 23)), true);
      expect(ev.isInQuietHours(qh, DateTime(2026, 4, 29, 6)), true);
      expect(ev.isInQuietHours(qh, DateTime(2026, 4, 29, 7)), false);
      expect(ev.isInQuietHours(qh, DateTime(2026, 4, 29, 12)), false);
      expect(ev.isInQuietHours(qh, DateTime(2026, 4, 29, 22)), true);
    });
  });
}
