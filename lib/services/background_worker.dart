import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../models/app_notification.dart';
import 'air_quality_evaluator.dart';
import 'air_quality_service.dart';
import 'notification_repository.dart';
import 'notification_service.dart';

const String airQualityCheckTask = 'airQualityCheck';
const String airQualityCheckTaskUnique = 'air-quality-check';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == airQualityCheckTask || task == Workmanager.iOSBackgroundTask) {
      try {
        // Check if critical alerts are enabled
        final prefs = await SharedPreferences.getInstance();
        final enabled = prefs.getBool('critical_alerts_enabled') ?? false;
        if (!enabled) return true;

        // Initialize notification plugin for background
        await NotificationService.instance.init();

        // Fetch all stations
        final service = AirQualityService();
        final stations = await service.fetchStations();

        // Evaluate for unhealthy conditions
        final alerts = evaluateStations(stations);

        // Process each alert with cooldown check
        final repository = NotificationRepository();
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
            await NotificationService.instance
                .showAirQualityAlert(notification);
          }
        }
      } catch (e) {
        // Silently fail in background — don't crash the worker
        return true;
      }
    }
    return true;
  });
}
