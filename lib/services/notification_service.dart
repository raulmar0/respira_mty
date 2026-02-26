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

  void checkAndNotify(List<Station> stations) {
    // Buscar la estación con peores niveles
    double maxPm10 = 0;
    double maxPm25 = 0;
    String worstPm10Station = '';
    String worstPm25Station = '';

    for (var station in stations) {
      if (station.pm10 != null && station.pm10! > maxPm10) {
        maxPm10 = station.pm10!;
        worstPm10Station = station.name;
      }
      if (station.pm25 != null && station.pm25! > maxPm25) {
        maxPm25 = station.pm25!;
        worstPm25Station = station.name;
      }
    }

    String? alertTitle;
    String? alertBody;

    // Verificar Contingencia Fase II
    if (maxPm10 >= 215 || maxPm25 >= 115) {
      alertTitle = '🚨 Contingencia Ambiental Fase II';
      alertBody = 'Niveles críticos en Nuevo León. Evita actividades al aire libre.';
    } 
    // Verificar Contingencia Fase I
    else if (maxPm10 >= 165 || maxPm25 >= 85) {
      alertTitle = '⚠️ Contingencia Ambiental Fase I';
      alertBody = 'Mala calidad del aire detectada. Toma precauciones.';
    } 
    // Verificar Alerta Ambiental
    else if (maxPm10 >= 140 || maxPm25 >= 70) {
      alertTitle = '🔔 Alerta Ambiental';
      alertBody = 'Calidad del aire riesgosa para grupos sensibles.';
    }

    if (alertTitle != null && alertBody != null) {
      showEnvironmentalAlert(alertTitle, alertBody);
    }
  }
}
