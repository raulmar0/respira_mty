import 'package:flutter_test/flutter_test.dart';
import 'package:respira_mty/models/alert_event.dart';
import 'package:respira_mty/services/alerts/alert_history_repository.dart';
import 'package:respira_mty/utils/air_quality_scale.dart';
import 'package:shared_preferences/shared_preferences.dart';

AlertEvent buildEvent({
  required String id,
  String stationId = 'centro',
  AirQualityCategory category = AirQualityCategory.veryBad,
  DateTime? firedAt,
  bool read = false,
}) {
  return AlertEvent(
    id: id,
    stationId: stationId,
    stationName: 'Test Station',
    category: category,
    dominantPollutant: 'PM2.5',
    dominantValue: 100.0,
    unit: 'µg/m³',
    firedAt: firedAt ?? DateTime.utc(2026, 4, 29, 12),
    localeAtFire: 'es',
    titleSnapshot: 'title',
    bodySnapshot: 'body',
    read: read,
    reason: AlertReason.crossingThreshold,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AlertHistoryRepository', () {
    test('loadAll returns empty list when key absent', () async {
      final repo = AlertHistoryRepository();
      final events = await repo.loadAll();
      expect(events, isEmpty);
    });

    test('append adds event at index 0 (newest first)', () async {
      final repo = AlertHistoryRepository();
      await repo.append(buildEvent(id: 'e1'));
      await repo.append(buildEvent(id: 'e2'));
      await repo.append(buildEvent(id: 'e3'));
      final all = await repo.loadAll();
      expect(all.length, 3);
      // newest first => 'e3' at index 0
      expect(all[0].id, 'e3');
      expect(all[1].id, 'e2');
      expect(all[2].id, 'e1');
    });

    test('FIFO eviction at maxEntries+1 (oldest dropped)', () async {
      final repo = AlertHistoryRepository();
      // Fill to maxEntries
      for (var i = 0; i < AlertHistoryRepository.maxEntries; i++) {
        await repo.append(buildEvent(id: 'e$i'));
      }
      var all = await repo.loadAll();
      expect(all.length, AlertHistoryRepository.maxEntries);
      // Append one more — oldest (e0) should be evicted
      await repo.append(buildEvent(id: 'eExtra'));
      all = await repo.loadAll();
      expect(all.length, AlertHistoryRepository.maxEntries);
      expect(all[0].id, 'eExtra');
      // 'e0' (the original first) should be gone
      expect(all.map((e) => e.id).contains('e0'), false);
      // 'e1' should still be the oldest
      expect(all.last.id, 'e1');
    });

    test('markRead is idempotent', () async {
      final repo = AlertHistoryRepository();
      await repo.append(buildEvent(id: 'e1'));
      await repo.markRead('e1');
      var loaded = await repo.loadAll();
      expect(loaded.first.read, true);
      // call again
      await repo.markRead('e1');
      loaded = await repo.loadAll();
      expect(loaded.first.read, true);
      expect(loaded.length, 1);
    });

    test('markRead on non-existent id does not throw', () async {
      final repo = AlertHistoryRepository();
      await repo.append(buildEvent(id: 'e1'));
      await repo.markRead('non-existent');
      final loaded = await repo.loadAll();
      expect(loaded.first.read, false);
    });

    test('markAllRead clears all dots', () async {
      final repo = AlertHistoryRepository();
      await repo.append(buildEvent(id: 'e1'));
      await repo.append(buildEvent(id: 'e2'));
      await repo.append(buildEvent(id: 'e3'));
      await repo.markAllRead();
      final loaded = await repo.loadAll();
      expect(loaded.every((e) => e.read), true);
    });

    test('clear empties storage', () async {
      final repo = AlertHistoryRepository();
      await repo.append(buildEvent(id: 'e1'));
      await repo.append(buildEvent(id: 'e2'));
      await repo.clear();
      final loaded = await repo.loadAll();
      expect(loaded, isEmpty);
    });

    test('corrupt JSON returns empty list (no throw)', () async {
      SharedPreferences.setMockInitialValues({
        AlertHistoryRepository.key: 'not json',
      });
      final repo = AlertHistoryRepository();
      final loaded = await repo.loadAll();
      expect(loaded, isEmpty);
    });
  });
}
