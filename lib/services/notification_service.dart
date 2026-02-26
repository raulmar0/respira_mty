import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import '../models/station.dart';

enum AlertLevel { none, alerta, fase1, fase2 }

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  AlertLevel _lastAlertLevel = AlertLevel.none;

  Future<void> init() async {
    if (_initialized) return;

    try {
      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // Request permissions for Android 13+
      if (defaultTargetPlatform == TargetPlatform.android) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        await androidImplementation?.requestNotificationsPermission();
      }

      _initialized = true;
    } catch (e) {
      debugPrint('Failed to initialize NotificationService: $e');
    }
  }

  Future<void> showEnvironmentalAlert(int id, String title, String body) async {
    if (!_initialized) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'environmental_alerts_channel',
      'Alertas Ambientales',
      channelDescription: 'Notificaciones sobre la calidad del aire y contingencias.',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  /// Returns the alert title, body, and severity level for the given pollutant levels, 
  /// or null if the levels do not reach any alert threshold.
  static ({String title, String body, AlertLevel level})? getAlertForLevels(
      double maxPm10, double maxPm25) {
    if (maxPm10 >= 215 || maxPm25 >= 115) {
      return (
        title: '🚨 Contingencia Ambiental Fase II',
        body: 'Niveles críticos en Nuevo León. Evita actividades al aire libre.',
        level: AlertLevel.fase2,
      );
    }
    if (maxPm10 >= 165 || maxPm25 >= 85) {
      return (
        title: '⚠️ Contingencia Ambiental Fase I',
        body: 'Mala calidad del aire detectada. Toma precauciones.',
        level: AlertLevel.fase1,
      );
    }
    if (maxPm10 >= 140 || maxPm25 >= 70) {
      return (
        title: '🔔 Alerta Ambiental',
        body: 'Calidad del aire riesgosa para grupos sensibles.',
        level: AlertLevel.alerta,
      );
    }
    return null;
  }

  Future<void> checkAndNotify(List<Station> stations) async {
    if (!_initialized) return;

    double maxPm10 = 0;
    double maxPm25 = 0;

    for (var station in stations) {
      if (station.pm10 != null && station.pm10! > maxPm10) {
        maxPm10 = station.pm10!;
      }
      if (station.pm25 != null && station.pm25! > maxPm25) {
        maxPm25 = station.pm25!;
      }
    }

    final alert = getAlertForLevels(maxPm10, maxPm25);
    
    if (alert != null) {
      // Only notify if the alert level has escalated or changed to a new severity
      if (_lastAlertLevel != alert.level) {
        _lastAlertLevel = alert.level;
        // Use the title's hashCode as ID to distinguish alerts if necessary
        await showEnvironmentalAlert(alert.title.hashCode, alert.title, alert.body);
      }
    } else {
      // Reset if air is good
      _lastAlertLevel = AlertLevel.none;
    }
  }
}
