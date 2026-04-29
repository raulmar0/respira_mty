import 'package:respira_mty/utils/air_quality_scale.dart';

import 'alert_event.dart' show AlertReason;

/// Ephemeral output of [AlertEvaluator]. Mapped to [AlertEvent] at fire time
/// (after copy is resolved against AppLocalizations).
class AlertRule {
  final String stationId;
  final String stationName;
  final AirQualityCategory category;
  final AirQualityCategory? previousCategory;
  final String dominantPollutant;
  final double value;
  final String unit;
  final AlertReason reason;

  const AlertRule({
    required this.stationId,
    required this.stationName,
    required this.category,
    required this.previousCategory,
    required this.dominantPollutant,
    required this.value,
    required this.unit,
    required this.reason,
  });
}
