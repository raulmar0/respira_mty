import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_notification.dart';
import '../services/air_quality_evaluator.dart';
import '../services/notification_repository.dart';
import '../services/notification_service.dart';
import 'settings_provider.dart';
import 'station_provider.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

class NotificationHistoryNotifier
    extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    return ref.read(notificationRepositoryProvider).getAll();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(
      await ref.read(notificationRepositoryProvider).getAll(),
    );
  }

  Future<void> markAsRead(String id) async {
    await ref.read(notificationRepositoryProvider).markAsRead(id);
    await refresh();
  }

  Future<void> markAllAsRead() async {
    await ref.read(notificationRepositoryProvider).markAllAsRead();
    await refresh();
  }

  Future<void> addNotification(AppNotification notification) async {
    await ref.read(notificationRepositoryProvider).add(notification);
    await refresh();
  }
}

final notificationHistoryProvider =
    AsyncNotifierProvider<NotificationHistoryNotifier, List<AppNotification>>(
  NotificationHistoryNotifier.new,
);

final unreadNotificationCountProvider = Provider<int>((ref) {
  final history = ref.watch(notificationHistoryProvider);
  return history.whenOrNull(data: (list) => list.where((n) => !n.isRead).length) ?? 0;
});

/// Foreground alert evaluator — runs when station data refreshes while the app is open.
final foregroundAlertProvider = Provider<void>((ref) {
  final criticalEnabled = ref.watch(criticalAlertsProvider);
  if (!criticalEnabled) return;

  final stationsAsync = ref.watch(airQualityProvider);

  stationsAsync.whenData((stations) async {
    final alerts = evaluateStations(stations);
    final repository = ref.read(notificationRepositoryProvider);

    for (final alert in alerts) {
      final category = alert.dominantPollutant.category;
      final shouldNotify =
          await repository.shouldAlert(alert.station.id, category);

      if (shouldNotify) {
        final notification = AppNotification(
          id: '${alert.station.id}_${DateTime.now().millisecondsSinceEpoch}',
          stationId: alert.station.id,
          stationName: alert.station.name,
          pollutantName: alert.dominantPollutant.name,
          pollutantValue: alert.dominantPollutant.value,
          pollutantUnit: alert.dominantPollutant.unit,
          category: category,
          createdAt: DateTime.now(),
        );

        await repository.add(notification);
        await repository.recordAlert(alert.station.id, category);
        await NotificationService.instance.showAirQualityAlert(notification);

        // Refresh UI history
        ref.read(notificationHistoryProvider.notifier).refresh();
      }
    }
  });
});
