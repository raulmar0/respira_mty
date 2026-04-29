import 'dart:convert';

import 'package:respira_mty/models/alert_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the alert history (newest first) with FIFO eviction.
class AlertHistoryRepository {
  static const String key = 'alert_history_v1';
  static const int maxEntries = 100;

  Future<List<AlertEvent>> loadAll() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(key);
    if (raw == null || raw.isEmpty) return <AlertEvent>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <AlertEvent>[];
      return decoded
          .map((e) => AlertEvent.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return <AlertEvent>[];
    }
  }

  Future<void> append(AlertEvent e) async {
    final list = await loadAll();
    // newest first
    list.insert(0, e);
    if (list.length > maxEntries) {
      // FIFO eviction: drop the oldest entries (tail).
      list.removeRange(maxEntries, list.length);
    }
    await _writeAll(list);
  }

  Future<void> markAllRead() async {
    final list = await loadAll();
    final updated = list.map((e) => e.copyWith(read: true)).toList();
    await _writeAll(updated);
  }

  Future<void> markRead(String id) async {
    final list = await loadAll();
    final updated = list
        .map((e) => e.id == id ? e.copyWith(read: true) : e)
        .toList();
    await _writeAll(updated);
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(key);
  }

  Future<void> _writeAll(List<AlertEvent> list) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(key, jsonEncode(list.map((e) => e.toJson()).toList()));
  }
}
