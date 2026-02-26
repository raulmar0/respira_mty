import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/station.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

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
    _initialized = true;
  }

  Future<void> showEnvironmentalAlert(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'environmental_alerts_channel',
      'Alertas Ambientales',
      channelDescription: 'Notificaciones sobre la calidad del aire y contingencias.',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  /// Returns the alert title and body for the given pollutant levels, or null
  /// if the levels do not reach any alert threshold. This method is static so
  /// that it can be exercised in unit tests without initialising the plugin.
  static ({String title, String body})? getAlertForLevels(
      double maxPm10, double maxPm25) {
    // Verificar Contingencia Fase II
    if (maxPm10 >= 215 || maxPm25 >= 115) {
      return (
        title: '🚨 Contingencia Ambiental Fase II',
        body: 'Niveles críticos en Nuevo León. Evita actividades al aire libre.',
      );
    }
    // Verificar Contingencia Fase I
    if (maxPm10 >= 165 || maxPm25 >= 85) {
      return (
        title: '⚠️ Contingencia Ambiental Fase I',
        body: 'Mala calidad del aire detectada. Toma precauciones.',
      );
    }
    // Verificar Alerta Ambiental
    if (maxPm10 >= 140 || maxPm25 >= 70) {
      return (
        title: '🔔 Alerta Ambiental',
        body: 'Calidad del aire riesgosa para grupos sensibles.',
      );
    }
    return null;
  }

  void checkAndNotify(List<Station> stations) {
    // Buscar la estación con peores niveles
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
      showEnvironmentalAlert(alert.title, alert.body);
    }
  }
}
