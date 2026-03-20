import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/app_notification.dart';
import '../utils/air_quality_scale.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'air_quality_alerts';
  static const String _channelName = 'Air Quality Alerts';
  static const String _channelDescription =
      'Notifications when air quality reaches unhealthy levels';

  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
  }

  Future<void> showAirQualityAlert(AppNotification notification) async {
    final priority = _priorityForCategory(notification.category);
    final importance = _importanceForCategory(notification.category);

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: importance,
      priority: priority,
      ticker: 'Air Quality Alert',
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final statusText =
        AirQualityScale.getStatusForCategory(notification.category);

    await _plugin.show(
      notification.stationId.hashCode,
      'Calidad del aire: $statusText',
      '${notification.pollutantName} en ${notification.stationName}: '
          '${notification.pollutantValue.toStringAsFixed(notification.pollutantName == "CO" ? 1 : 0)} '
          '${notification.pollutantUnit}',
      details,
    );
  }

  Priority _priorityForCategory(AirQualityCategory category) {
    switch (category) {
      case AirQualityCategory.extremelyBad:
      case AirQualityCategory.veryBad:
        return Priority.max;
      case AirQualityCategory.bad:
        return Priority.high;
      default:
        return Priority.defaultPriority;
    }
  }

  Importance _importanceForCategory(AirQualityCategory category) {
    switch (category) {
      case AirQualityCategory.extremelyBad:
      case AirQualityCategory.veryBad:
        return Importance.max;
      case AirQualityCategory.bad:
        return Importance.high;
      default:
        return Importance.defaultImportance;
    }
  }
}
