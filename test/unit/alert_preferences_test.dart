import 'package:flutter_test/flutter_test.dart';
import 'package:respira_mty/models/alert_preferences.dart';
import 'package:respira_mty/utils/air_quality_scale.dart';

void main() {
  group('QuietHours', () {
    test('defaults: 22:00 start, 07:00 end, disabled', () {
      const qh = QuietHours.defaults();
      expect(qh.startMinute, 22 * 60);
      expect(qh.endMinute, 7 * 60);
      expect(qh.enabled, false);
    });

    test('toJson / fromJson round-trip', () {
      const qh = QuietHours(startMinute: 100, endMinute: 200, enabled: true);
      final json = qh.toJson();
      final restored = QuietHours.fromJson(json);
      expect(restored.startMinute, 100);
      expect(restored.endMinute, 200);
      expect(restored.enabled, true);
    });

    test('copyWith preserves untouched fields', () {
      const qh = QuietHours(startMinute: 100, endMinute: 200, enabled: false);
      final c1 = qh.copyWith(enabled: true);
      expect(c1.enabled, true);
      expect(c1.startMinute, 100);
      expect(c1.endMinute, 200);

      final c2 = qh.copyWith(startMinute: 300);
      expect(c2.startMinute, 300);
      expect(c2.endMinute, 200);
      expect(c2.enabled, false);
    });

    test('edge values: start==end (zero-length window)', () {
      const qh = QuietHours(startMinute: 600, endMinute: 600, enabled: true);
      final json = qh.toJson();
      final restored = QuietHours.fromJson(json);
      expect(restored.startMinute, restored.endMinute);
    });

    test('edge values: start>end (crosses midnight)', () {
      const qh = QuietHours(startMinute: 1320, endMinute: 420, enabled: true);
      final json = qh.toJson();
      final restored = QuietHours.fromJson(json);
      expect(restored.startMinute, 1320);
      expect(restored.endMinute, 420);
    });

    test('edge values: start<end (same-day window)', () {
      const qh = QuietHours(startMinute: 60, endMinute: 120, enabled: true);
      final json = qh.toJson();
      final restored = QuietHours.fromJson(json);
      expect(restored.startMinute, 60);
      expect(restored.endMinute, 120);
    });
  });

  group('AlertPreferences', () {
    test('defaults match spec', () {
      final p = AlertPreferences.defaults();
      expect(p.enabled, false);
      expect(p.threshold, AirQualityCategory.veryBad);
      expect(p.scope, AlertScope.favorites);
      expect(p.nearestRadiusKm, 5);
      expect(p.quietHours.enabled, false);
      expect(p.mutedPollutants, isEmpty);
      expect(p.cooldownHours, 6);
      expect(p.notifyOnImprovement, false);
    });

    test('toJson / fromJson round-trip preserves enums by name', () {
      final p = AlertPreferences(
        enabled: true,
        threshold: AirQualityCategory.bad,
        scope: AlertScope.nearest,
        nearestRadiusKm: 8,
        quietHours: const QuietHours(
          startMinute: 1320,
          endMinute: 420,
          enabled: true,
        ),
        mutedPollutants: const <String>{'O3', 'CO'},
        cooldownHours: 12,
        notifyOnImprovement: true,
      );
      final json = p.toJson();
      // Verify enums serialize by name
      expect(json['threshold'], 'bad');
      expect(json['scope'], 'nearest');
      // muted set serializes as JSON array
      expect(json['mutedPollutants'], isA<List<dynamic>>());

      final restored = AlertPreferences.fromJson(json);
      expect(restored.enabled, p.enabled);
      expect(restored.threshold, p.threshold);
      expect(restored.scope, p.scope);
      expect(restored.nearestRadiusKm, p.nearestRadiusKm);
      expect(restored.quietHours.startMinute, p.quietHours.startMinute);
      expect(restored.quietHours.endMinute, p.quietHours.endMinute);
      expect(restored.quietHours.enabled, p.quietHours.enabled);
      expect(restored.mutedPollutants, p.mutedPollutants);
      expect(restored.cooldownHours, p.cooldownHours);
      expect(restored.notifyOnImprovement, p.notifyOnImprovement);
    });

    test('copyWith preserves untouched fields', () {
      final p = AlertPreferences.defaults();
      final p2 = p.copyWith(enabled: true);
      expect(p2.enabled, true);
      expect(p2.threshold, p.threshold);
      expect(p2.scope, p.scope);
      expect(p2.nearestRadiusKm, p.nearestRadiusKm);
      expect(p2.quietHours.startMinute, p.quietHours.startMinute);
      expect(p2.mutedPollutants, p.mutedPollutants);
      expect(p2.cooldownHours, p.cooldownHours);
      expect(p2.notifyOnImprovement, p.notifyOnImprovement);
    });

    test('copyWith updates multiple fields independently', () {
      final p = AlertPreferences.defaults();
      final p2 = p.copyWith(
        threshold: AirQualityCategory.bad,
        scope: AlertScope.all,
        cooldownHours: 12,
      );
      expect(p2.threshold, AirQualityCategory.bad);
      expect(p2.scope, AlertScope.all);
      expect(p2.cooldownHours, 12);
      // unchanged
      expect(p2.enabled, false);
      expect(p2.nearestRadiusKm, 5);
    });
  });
}
