import 'package:flutter_test/flutter_test.dart';
import 'package:respira_mty/services/alerts/alert_baseline_store.dart';
import 'package:respira_mty/utils/air_quality_scale.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AlertBaselineStore', () {
    test('load returns empty map when key absent', () async {
      final store = AlertBaselineStore();
      final m = await store.load();
      expect(m, isEmpty);
    });

    test('upsert single station', () async {
      final store = AlertBaselineStore();
      await store.upsert(
        'centro',
        AirQualityCategory.veryBad,
        DateTime.utc(2026, 4, 29, 10),
      );
      final m = await store.load();
      expect(m.length, 1);
      expect(m['centro'], AirQualityCategory.veryBad);
    });

    test('upsert multiple stations', () async {
      final store = AlertBaselineStore();
      await store.upsert(
        'centro',
        AirQualityCategory.veryBad,
        DateTime.utc(2026, 4, 29, 10),
      );
      await store.upsert(
        'norte',
        AirQualityCategory.good,
        DateTime.utc(2026, 4, 29, 11),
      );
      await store.upsert(
        'centro',
        AirQualityCategory.bad,
        DateTime.utc(2026, 4, 29, 12),
      );
      final m = await store.load();
      expect(m.length, 2);
      expect(m['centro'], AirQualityCategory.bad);
      expect(m['norte'], AirQualityCategory.good);
    });

    test('seed bulk-writes a snapshot', () async {
      final store = AlertBaselineStore();
      await store.seed({
        'centro': AirQualityCategory.bad,
        'norte': AirQualityCategory.good,
        'sureste': AirQualityCategory.veryBad,
      });
      final m = await store.load();
      expect(m.length, 3);
      expect(m['centro'], AirQualityCategory.bad);
      expect(m['norte'], AirQualityCategory.good);
      expect(m['sureste'], AirQualityCategory.veryBad);
    });

    test('isEmpty true when no key', () async {
      final store = AlertBaselineStore();
      expect(await store.isEmpty(), true);
    });

    test('isEmpty true when key exists with empty map', () async {
      final store = AlertBaselineStore();
      await store.seed({});
      expect(await store.isEmpty(), true);
    });

    test('isEmpty false when populated', () async {
      final store = AlertBaselineStore();
      await store.upsert(
        'centro',
        AirQualityCategory.bad,
        DateTime.utc(2026, 4, 29),
      );
      expect(await store.isEmpty(), false);
    });

    test('clear empties storage', () async {
      final store = AlertBaselineStore();
      await store.upsert(
        'centro',
        AirQualityCategory.bad,
        DateTime.utc(2026, 4, 29),
      );
      await store.clear();
      expect(await store.isEmpty(), true);
      final m = await store.load();
      expect(m, isEmpty);
    });

    test('corrupt JSON returns empty map (no throw)', () async {
      SharedPreferences.setMockInitialValues({
        AlertBaselineStore.key: 'not-json',
      });
      final store = AlertBaselineStore();
      final m = await store.load();
      expect(m, isEmpty);
    });
  });
}
