import 'package:flutter_test/flutter_test.dart';
import 'package:respira_mty/models/alert_event.dart';
import 'package:respira_mty/utils/air_quality_scale.dart';

void main() {
  group('AlertEvent', () {
    AlertEvent buildSample() => AlertEvent(
      id: 'abc-123',
      stationId: 'centro',
      stationName: 'Monterrey, Obispado',
      category: AirQualityCategory.veryBad,
      dominantPollutant: 'PM2.5',
      dominantValue: 142.0,
      unit: 'µg/m³',
      firedAt: DateTime.utc(2026, 4, 29, 12, 34, 56),
      localeAtFire: 'es',
      titleSnapshot: 'Calidad del aire muy mala',
      bodySnapshot: 'PM2.5 está en 142 µg/m³ en Monterrey',
      read: false,
      reason: AlertReason.crossingThreshold,
    );

    test('toJson / fromJson round-trip preserves all fields', () {
      final e = buildSample();
      final json = e.toJson();
      final r = AlertEvent.fromJson(json);
      expect(r.id, e.id);
      expect(r.stationId, e.stationId);
      expect(r.stationName, e.stationName);
      expect(r.category, e.category);
      expect(r.dominantPollutant, e.dominantPollutant);
      expect(r.dominantValue, e.dominantValue);
      expect(r.unit, e.unit);
      expect(r.firedAt.toUtc(), e.firedAt.toUtc());
      expect(r.localeAtFire, e.localeAtFire);
      expect(r.titleSnapshot, e.titleSnapshot);
      expect(r.bodySnapshot, e.bodySnapshot);
      expect(r.read, e.read);
      expect(r.reason, e.reason);
    });

    test('firedAt persists as UTC even if input was local', () {
      final local = DateTime(2026, 4, 29, 12, 34, 56);
      final e = AlertEvent(
        id: 'x',
        stationId: 's',
        stationName: 'S',
        category: AirQualityCategory.bad,
        dominantPollutant: 'PM10',
        dominantValue: 100.0,
        unit: 'µg/m³',
        firedAt: local,
        localeAtFire: 'en',
        titleSnapshot: 't',
        bodySnapshot: 'b',
        read: false,
        reason: AlertReason.crossingThreshold,
      );
      final json = e.toJson();
      final firedAtStr = json['firedAt'] as String;
      // Must end in 'Z' (UTC)
      expect(firedAtStr.endsWith('Z'), true);
      // round-trip equivalence
      final r = AlertEvent.fromJson(json);
      expect(r.firedAt.isAtSameMomentAs(local), true);
    });

    test('reason enum serializes by name', () {
      final e = buildSample().copyWith();
      // Test all three reasons round-trip
      for (final reason in AlertReason.values) {
        final src = AlertEvent(
          id: e.id,
          stationId: e.stationId,
          stationName: e.stationName,
          category: e.category,
          dominantPollutant: e.dominantPollutant,
          dominantValue: e.dominantValue,
          unit: e.unit,
          firedAt: e.firedAt,
          localeAtFire: e.localeAtFire,
          titleSnapshot: e.titleSnapshot,
          bodySnapshot: e.bodySnapshot,
          read: e.read,
          reason: reason,
        );
        final restored = AlertEvent.fromJson(src.toJson());
        expect(restored.reason, reason);
      }
    });

    test('copyWith updates only read', () {
      final e = buildSample();
      final r = e.copyWith(read: true);
      expect(r.read, true);
      expect(r.id, e.id);
      expect(r.stationId, e.stationId);
      expect(r.firedAt, e.firedAt);
    });

    test('generateId returns unique ids on consecutive calls', () {
      final ids = <String>{};
      for (var i = 0; i < 50; i++) {
        ids.add(AlertEvent.generateId());
      }
      expect(ids.length, 50);
    });

    test('generateId returns non-empty string', () {
      final id = AlertEvent.generateId();
      expect(id, isNotEmpty);
      expect(id.length, greaterThan(8));
    });
  });
}
