import 'dart:math' as math;

import 'package:respira_mty/utils/air_quality_scale.dart';

/// Why an alert was raised.
enum AlertReason {
  /// First time crossing into the threshold zone.
  crossingThreshold,

  /// Already at/above threshold, but the category index increased.
  worseningCategory,

  /// Recovery from above-threshold to good (only if user opted in).
  improvementBackToGood,
}

/// A persisted alert event. Kept for the in-app inbox and for cooldown.
class AlertEvent {
  final String id;
  final String stationId;
  final String stationName;
  final AirQualityCategory category;
  final String dominantPollutant;
  final double dominantValue;
  final String unit;
  final DateTime firedAt;
  final String localeAtFire;
  final String titleSnapshot;
  final String bodySnapshot;
  final bool read;
  final AlertReason reason;

  const AlertEvent({
    required this.id,
    required this.stationId,
    required this.stationName,
    required this.category,
    required this.dominantPollutant,
    required this.dominantValue,
    required this.unit,
    required this.firedAt,
    required this.localeAtFire,
    required this.titleSnapshot,
    required this.bodySnapshot,
    required this.read,
    required this.reason,
  });

  AlertEvent copyWith({bool? read}) => AlertEvent(
    id: id,
    stationId: stationId,
    stationName: stationName,
    category: category,
    dominantPollutant: dominantPollutant,
    dominantValue: dominantValue,
    unit: unit,
    firedAt: firedAt,
    localeAtFire: localeAtFire,
    titleSnapshot: titleSnapshot,
    bodySnapshot: bodySnapshot,
    read: read ?? this.read,
    reason: reason,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'stationId': stationId,
    'stationName': stationName,
    'category': category.name,
    'dominantPollutant': dominantPollutant,
    'dominantValue': dominantValue,
    'unit': unit,
    // Always store as UTC ISO8601.
    'firedAt': firedAt.toUtc().toIso8601String(),
    'localeAtFire': localeAtFire,
    'titleSnapshot': titleSnapshot,
    'bodySnapshot': bodySnapshot,
    'read': read,
    'reason': reason.name,
  };

  factory AlertEvent.fromJson(Map<String, dynamic> j) => AlertEvent(
    id: j['id'] as String,
    stationId: j['stationId'] as String,
    stationName: j['stationName'] as String,
    category: AirQualityCategory.values.firstWhere(
      (c) => c.name == j['category'],
      orElse: () => AirQualityCategory.maintenance,
    ),
    dominantPollutant: j['dominantPollutant'] as String,
    dominantValue: (j['dominantValue'] as num).toDouble(),
    unit: j['unit'] as String,
    firedAt: DateTime.parse(j['firedAt'] as String),
    localeAtFire: j['localeAtFire'] as String,
    titleSnapshot: j['titleSnapshot'] as String,
    bodySnapshot: j['bodySnapshot'] as String,
    read: j['read'] as bool,
    reason: AlertReason.values.firstWhere(
      (r) => r.name == j['reason'],
      orElse: () => AlertReason.crossingThreshold,
    ),
  );

  /// Generates a random hex id using Random.secure() for entropy.
  static String generateId() {
    final rng = math.Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    final hex = bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    return hex;
  }
}
