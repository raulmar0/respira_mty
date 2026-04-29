import 'dart:convert';

import 'package:respira_mty/utils/air_quality_scale.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the last-seen [AirQualityCategory] per station, used by the
/// evaluator to detect first-run, threshold crossings and worsening.
///
/// Internal storage:
/// `{stationId: {"category": "veryBad", "when": "2026-04-29T12:34:56Z"}}`.
class AlertBaselineStore {
  static const String key = 'alert_baseline_v1';

  Future<Map<String, AirQualityCategory>> load() async {
    final raw = await _readRaw();
    if (raw == null) return <String, AirQualityCategory>{};
    final map = <String, AirQualityCategory>{};
    raw.forEach((k, v) {
      if (v is Map) {
        final catName = v['category'] as String?;
        if (catName != null) {
          map[k] = AirQualityCategory.values.firstWhere(
            (c) => c.name == catName,
            orElse: () => AirQualityCategory.maintenance,
          );
        }
      }
    });
    return map;
  }

  Future<void> upsert(
    String stationId,
    AirQualityCategory c,
    DateTime when,
  ) async {
    final raw = await _readRaw() ?? <String, dynamic>{};
    raw[stationId] = <String, dynamic>{
      'category': c.name,
      'when': when.toUtc().toIso8601String(),
    };
    await _writeRaw(raw);
  }

  Future<void> seed(Map<String, AirQualityCategory> snapshot) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final out = <String, dynamic>{};
    snapshot.forEach((k, c) {
      out[k] = <String, dynamic>{'category': c.name, 'when': now};
    });
    await _writeRaw(out);
  }

  Future<bool> isEmpty() async {
    final raw = await _readRaw();
    return raw == null || raw.isEmpty;
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(key);
  }

  Future<Map<String, dynamic>?> _readRaw() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeRaw(Map<String, dynamic> raw) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(key, jsonEncode(raw));
  }
}
