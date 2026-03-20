import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_notification.dart';
import '../utils/air_quality_scale.dart';

class NotificationRepository {
  static const String _historyKey = 'notification_history';
  static const String _cooldownsKey = 'notification_cooldowns';
  static const int _maxNotifications = 50;
  static const Duration _cooldownDuration = Duration(hours: 3);

  Future<List<AppNotification>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_historyKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> add(AppNotification notification) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    all.insert(0, notification);
    // Cap at max
    final capped = all.length > _maxNotifications
        ? all.sublist(0, _maxNotifications)
        : all;
    await prefs.setString(
      _historyKey,
      jsonEncode(capped.map((n) => n.toJson()).toList()),
    );
  }

  Future<void> markAsRead(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    final updated = all.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
    await prefs.setString(
      _historyKey,
      jsonEncode(updated.map((n) => n.toJson()).toList()),
    );
  }

  Future<void> markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    final updated = all.map((n) => n.copyWith(isRead: true)).toList();
    await prefs.setString(
      _historyKey,
      jsonEncode(updated.map((n) => n.toJson()).toList()),
    );
  }

  /// Check if we should alert for this station given cooldown rules.
  /// Returns true if:
  /// - No previous alert for this station, OR
  /// - The new category is worse than the last alerted category, OR
  /// - More than 3 hours since the last alert for same/better category.
  Future<bool> shouldAlert(String stationId, AirQualityCategory category) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_cooldownsKey);
    if (json == null) return true;

    final cooldowns = jsonDecode(json) as Map<String, dynamic>;
    final entry = cooldowns[stationId];
    if (entry == null) return true;

    final lastTimestamp = DateTime.parse(entry['timestamp'] as String);
    final lastCategoryIndex = entry['categoryIndex'] as int;

    // Worse category → always alert
    if (category.index > lastCategoryIndex) return true;

    // Same or better category → check cooldown
    final elapsed = DateTime.now().difference(lastTimestamp);
    return elapsed >= _cooldownDuration;
  }

  Future<void> recordAlert(String stationId, AirQualityCategory category) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_cooldownsKey);
    final cooldowns = json != null
        ? (jsonDecode(json) as Map<String, dynamic>)
        : <String, dynamic>{};

    cooldowns[stationId] = {
      'timestamp': DateTime.now().toIso8601String(),
      'categoryIndex': category.index,
    };

    await prefs.setString(_cooldownsKey, jsonEncode(cooldowns));
  }
}
