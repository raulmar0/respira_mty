import 'dart:convert';

import 'package:respira_mty/models/alert_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists [AlertPreferences] to shared_preferences as a single JSON blob.
class AlertPreferencesRepository {
  static const String key = 'alert_prefs_v1';

  Future<AlertPreferences> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(key);
    if (raw == null || raw.isEmpty) {
      return AlertPreferences.defaults();
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return AlertPreferences.fromJson(decoded);
      }
      return AlertPreferences.defaults();
    } catch (_) {
      // Corrupt JSON or schema mismatch — fall back to defaults.
      return AlertPreferences.defaults();
    }
  }

  Future<void> save(AlertPreferences p) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(key, jsonEncode(p.toJson()));
  }
}
