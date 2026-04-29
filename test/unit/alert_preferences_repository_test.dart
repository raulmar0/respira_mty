import 'package:flutter_test/flutter_test.dart';
import 'package:respira_mty/models/alert_preferences.dart';
import 'package:respira_mty/services/alerts/alert_preferences_repository.dart';
import 'package:respira_mty/utils/air_quality_scale.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AlertPreferencesRepository', () {
    test('load returns defaults when key absent', () async {
      final repo = AlertPreferencesRepository();
      final prefs = await repo.load();
      final defaults = AlertPreferences.defaults();
      expect(prefs.enabled, defaults.enabled);
      expect(prefs.threshold, defaults.threshold);
      expect(prefs.scope, defaults.scope);
      expect(prefs.nearestRadiusKm, defaults.nearestRadiusKm);
      expect(prefs.cooldownHours, defaults.cooldownHours);
      expect(prefs.notifyOnImprovement, defaults.notifyOnImprovement);
      expect(prefs.mutedPollutants, defaults.mutedPollutants);
    });

    test('save + load round-trip', () async {
      final repo = AlertPreferencesRepository();
      final p = AlertPreferences(
        enabled: true,
        threshold: AirQualityCategory.bad,
        scope: AlertScope.all,
        nearestRadiusKm: 7,
        quietHours: const QuietHours(
          startMinute: 100,
          endMinute: 200,
          enabled: true,
        ),
        mutedPollutants: const <String>{'O3'},
        cooldownHours: 8,
        notifyOnImprovement: true,
      );
      await repo.save(p);
      final loaded = await repo.load();
      expect(loaded.enabled, true);
      expect(loaded.threshold, AirQualityCategory.bad);
      expect(loaded.scope, AlertScope.all);
      expect(loaded.nearestRadiusKm, 7);
      expect(loaded.quietHours.enabled, true);
      expect(loaded.mutedPollutants, {'O3'});
      expect(loaded.cooldownHours, 8);
      expect(loaded.notifyOnImprovement, true);
    });

    test('corrupt JSON falls back to defaults (no throw)', () async {
      SharedPreferences.setMockInitialValues({
        AlertPreferencesRepository.key: 'this is not json',
      });
      final repo = AlertPreferencesRepository();
      final prefs = await repo.load();
      // Defaults
      expect(prefs.enabled, false);
      expect(prefs.threshold, AirQualityCategory.veryBad);
    });
  });
}
