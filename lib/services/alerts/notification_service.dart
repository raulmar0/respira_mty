import 'dart:io' show Platform;
import 'dart:ui' show Color;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:respira_mty/models/alert_event.dart';
import 'package:respira_mty/utils/air_quality_scale.dart';
import 'package:respira_mty/utils/app_colors.dart';
import 'package:timezone/data/latest.dart' as tz;

/// Top-level notification tap handler. Required by `flutter_local_notifications`
/// to be a top-level (or static) function annotated with `vm:entry-point` so
/// that tree-shaking does not eliminate it in release mode.
@pragma('vm:entry-point')
void notificationTapHandler(NotificationResponse response) {
  final stationId = response.payload;
  if (stationId != null && stationId.isNotEmpty) {
    NotificationService.pendingDeepLink = stationId;
  }
}

/// Singleton wrapper around [FlutterLocalNotificationsPlugin].
///
/// Both the foreground engine and the background isolate fire notifications
/// through [show], so all the platform glue (channel creation, permission
/// requests, payload routing) lives here.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  /// Stash for a pending deep-link from a notification tap that arrived while
  /// the app was terminated. `MainShell.initState` reads this and navigates if
  /// non-null, then clears it.
  static String? pendingDeepLink;

  /// Channel IDs (Android). One channel per severity level so users can mute
  /// individually in system settings.
  static const String channelBadId = 'air_quality_bad';
  static const String channelVeryBadId = 'air_quality_very_bad';
  static const String channelExtremeId = 'air_quality_extreme';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize the plugin. Idempotent.
  ///
  /// - Initializes timezone data (required by zonedSchedule).
  /// - Registers tap callbacks (foreground + background).
  /// - Creates the three Android notification channels.
  /// - On iOS, defers permission prompts until [requestPermission] is called.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: notificationTapHandler,
      onDidReceiveBackgroundNotificationResponse: notificationTapHandler,
    );

    await _createAndroidChannels();
  }

  Future<void> _createAndroidChannels() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    // Channel names live in Android system Settings → App → Notifications.
    // We pick Spanish copy because the primary user base is in Monterrey;
    // the rest of the app's localization happens at notification-fire time
    // via title/bodySnapshot, which is what the user actually sees in the
    // notification shade.
    const badChannel = AndroidNotificationChannel(
      channelBadId,
      'Calidad del aire mala',
      description: 'Notificaciones cuando el aire alcanza nivel Malo',
      importance: Importance.high,
    );
    const veryBadChannel = AndroidNotificationChannel(
      channelVeryBadId,
      'Calidad del aire muy mala',
      description:
          'Notificaciones cuando el aire alcanza nivel Muy Malo (contingencia)',
      importance: Importance.high,
    );
    const extremeChannel = AndroidNotificationChannel(
      channelExtremeId,
      'Calidad del aire extrema',
      description:
          'Notificaciones cuando el aire alcanza nivel Extremadamente Malo',
      importance: Importance.max,
    );

    await androidPlugin.createNotificationChannel(badChannel);
    await androidPlugin.createNotificationChannel(veryBadChannel);
    await androidPlugin.createNotificationChannel(extremeChannel);
  }

  /// Request notification permission.
  ///
  /// - On iOS: requests Alert + Badge + Sound via the plugin's iOS surface.
  /// - On Android 13+: requests POST_NOTIFICATIONS via permission_handler.
  ///   Returns true on Android <13 (legacy auto-granted behavior).
  ///
  /// Returns true if granted (or already granted), false otherwise.
  Future<bool> requestPermission() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    if (Platform.isAndroid) {
      final status = await ph.Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }

  /// Returns true if the OS reports notification permission as granted.
  Future<bool> isPermissionGranted() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final settings = await iosPlugin?.checkPermissions();
      return settings?.isAlertEnabled ?? false;
    }
    if (Platform.isAndroid) {
      return ph.Permission.notification.isGranted;
    }
    return true;
  }

  /// Opens the system app settings page so the user can change notification
  /// permission. Use when permission is denied and the user taps a CTA.
  Future<void> openSystemSettings() async {
    await ph.openAppSettings();
  }

  /// Show a notification for the given event.
  ///
  /// - Routes to a channel by [AlertEvent.category] (Android only).
  /// - Uses [AlertEvent.id]'s hashCode as the notification id (must be int).
  /// - Encodes [AlertEvent.stationId] as the payload so the tap handler can
  ///   deep-link into station detail.
  /// - Returns silently for events whose category isn't actionable (good /
  ///   acceptable / maintenance), as a defensive guard against callers
  ///   accidentally firing for non-alert states.
  Future<void> show(AlertEvent event) async {
    final channelId = _channelFor(event.category);
    if (channelId == null) return;
    final channelName = _channelNameFor(event.category);
    final channelDesc = _channelDescFor(event.category);
    final accent = _accentFor(event.category);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: event.category == AirQualityCategory.extremelyBad
          ? Importance.max
          : Importance.high,
      priority: Priority.high,
      color: accent,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      event.id.hashCode,
      event.titleSnapshot,
      event.bodySnapshot,
      details,
      payload: event.stationId,
    );
  }

  static String? _channelFor(AirQualityCategory category) {
    switch (category) {
      case AirQualityCategory.bad:
        return channelBadId;
      case AirQualityCategory.veryBad:
        return channelVeryBadId;
      case AirQualityCategory.extremelyBad:
        return channelExtremeId;
      case AirQualityCategory.good:
      case AirQualityCategory.acceptable:
      case AirQualityCategory.maintenance:
        return null;
    }
  }

  static String _channelNameFor(AirQualityCategory category) {
    switch (category) {
      case AirQualityCategory.bad:
        return 'Calidad del aire mala';
      case AirQualityCategory.veryBad:
        return 'Calidad del aire muy mala';
      case AirQualityCategory.extremelyBad:
        return 'Calidad del aire extrema';
      case AirQualityCategory.good:
      case AirQualityCategory.acceptable:
      case AirQualityCategory.maintenance:
        return 'Calidad del aire';
    }
  }

  static String _channelDescFor(AirQualityCategory category) {
    switch (category) {
      case AirQualityCategory.bad:
        return 'Notificaciones cuando el aire alcanza nivel Malo';
      case AirQualityCategory.veryBad:
        return 'Notificaciones cuando el aire alcanza nivel Muy Malo (contingencia)';
      case AirQualityCategory.extremelyBad:
        return 'Notificaciones cuando el aire alcanza nivel Extremadamente Malo';
      case AirQualityCategory.good:
      case AirQualityCategory.acceptable:
      case AirQualityCategory.maintenance:
        return 'Notificaciones de calidad del aire';
    }
  }

  static Color _accentFor(AirQualityCategory category) {
    switch (category) {
      case AirQualityCategory.bad:
        return AppColors.categoryBad;
      case AirQualityCategory.veryBad:
        return AppColors.categoryVeryBad;
      case AirQualityCategory.extremelyBad:
        return AppColors.categoryExtreme;
      case AirQualityCategory.good:
        return AppColors.categoryGood;
      case AirQualityCategory.acceptable:
        return AppColors.categoryAcceptable;
      case AirQualityCategory.maintenance:
        return AppColors.categoryMaintenance;
    }
  }
}
