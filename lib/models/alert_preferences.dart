import 'package:flutter/foundation.dart';
import 'package:respira_mty/utils/air_quality_scale.dart';

/// Scope for which stations are evaluated for alerts.
enum AlertScope { all, favorites, nearest }

/// Quiet hours window when alerts are suppressed.
class QuietHours {
  /// Minute of day at which quiet hours start (0..1439).
  final int startMinute;

  /// Minute of day at which quiet hours end (0..1439).
  final int endMinute;

  /// Whether the window is active. When false, the evaluator ignores it.
  final bool enabled;

  const QuietHours({
    required this.startMinute,
    required this.endMinute,
    required this.enabled,
  });

  /// Default 22:00 → 07:00 window, disabled until the user opts in.
  const QuietHours.defaults()
    : startMinute = 22 * 60,
      endMinute = 7 * 60,
      enabled = false;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'startMinute': startMinute,
    'endMinute': endMinute,
    'enabled': enabled,
  };

  factory QuietHours.fromJson(Map<String, dynamic> j) => QuietHours(
    startMinute: (j['startMinute'] as num).toInt(),
    endMinute: (j['endMinute'] as num).toInt(),
    enabled: j['enabled'] as bool,
  );

  QuietHours copyWith({int? startMinute, int? endMinute, bool? enabled}) =>
      QuietHours(
        startMinute: startMinute ?? this.startMinute,
        endMinute: endMinute ?? this.endMinute,
        enabled: enabled ?? this.enabled,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuietHours &&
          runtimeType == other.runtimeType &&
          startMinute == other.startMinute &&
          endMinute == other.endMinute &&
          enabled == other.enabled;

  @override
  int get hashCode => Object.hash(startMinute, endMinute, enabled);
}

/// User-tunable preferences for the contingency alert engine.
class AlertPreferences {
  final bool enabled;
  final AirQualityCategory threshold;
  final AlertScope scope;
  final int nearestRadiusKm;
  final QuietHours quietHours;
  final Set<String> mutedPollutants;
  final int cooldownHours;
  final bool notifyOnImprovement;

  const AlertPreferences({
    required this.enabled,
    required this.threshold,
    required this.scope,
    required this.nearestRadiusKm,
    required this.quietHours,
    required this.mutedPollutants,
    required this.cooldownHours,
    required this.notifyOnImprovement,
  });

  /// Sensible defaults for first launch.
  factory AlertPreferences.defaults() => const AlertPreferences(
    enabled: false,
    threshold: AirQualityCategory.veryBad,
    scope: AlertScope.favorites,
    nearestRadiusKm: 5,
    quietHours: QuietHours.defaults(),
    mutedPollutants: <String>{},
    cooldownHours: 6,
    notifyOnImprovement: false,
  );

  AlertPreferences copyWith({
    bool? enabled,
    AirQualityCategory? threshold,
    AlertScope? scope,
    int? nearestRadiusKm,
    QuietHours? quietHours,
    Set<String>? mutedPollutants,
    int? cooldownHours,
    bool? notifyOnImprovement,
  }) => AlertPreferences(
    enabled: enabled ?? this.enabled,
    threshold: threshold ?? this.threshold,
    scope: scope ?? this.scope,
    nearestRadiusKm: nearestRadiusKm ?? this.nearestRadiusKm,
    quietHours: quietHours ?? this.quietHours,
    mutedPollutants: mutedPollutants ?? this.mutedPollutants,
    cooldownHours: cooldownHours ?? this.cooldownHours,
    notifyOnImprovement: notifyOnImprovement ?? this.notifyOnImprovement,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'enabled': enabled,
    'threshold': threshold.name,
    'scope': scope.name,
    'nearestRadiusKm': nearestRadiusKm,
    'quietHours': quietHours.toJson(),
    'mutedPollutants': mutedPollutants.toList(),
    'cooldownHours': cooldownHours,
    'notifyOnImprovement': notifyOnImprovement,
  };

  factory AlertPreferences.fromJson(Map<String, dynamic> j) => AlertPreferences(
    enabled: j['enabled'] as bool,
    threshold: AirQualityCategory.values.firstWhere(
      (c) => c.name == j['threshold'],
      orElse: () => AirQualityCategory.veryBad,
    ),
    scope: AlertScope.values.firstWhere(
      (s) => s.name == j['scope'],
      orElse: () => AlertScope.favorites,
    ),
    nearestRadiusKm: (j['nearestRadiusKm'] as num).toInt(),
    quietHours: QuietHours.fromJson(
      Map<String, dynamic>.from(j['quietHours'] as Map),
    ),
    mutedPollutants: (j['mutedPollutants'] as List<dynamic>)
        .map((e) => e as String)
        .toSet(),
    cooldownHours: (j['cooldownHours'] as num).toInt(),
    notifyOnImprovement: j['notifyOnImprovement'] as bool,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertPreferences &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          threshold == other.threshold &&
          scope == other.scope &&
          nearestRadiusKm == other.nearestRadiusKm &&
          quietHours == other.quietHours &&
          setEquals(mutedPollutants, other.mutedPollutants) &&
          cooldownHours == other.cooldownHours &&
          notifyOnImprovement == other.notifyOnImprovement;

  @override
  int get hashCode => Object.hash(
        enabled,
        threshold,
        scope,
        nearestRadiusKm,
        quietHours,
        Object.hashAllUnordered(mutedPollutants),
        cooldownHours,
        notifyOnImprovement,
      );
}
