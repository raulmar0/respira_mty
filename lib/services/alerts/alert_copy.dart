import 'package:respira_mty/l10n/app_localizations.dart';
import 'package:respira_mty/models/alert_event.dart';
import 'package:respira_mty/models/alert_rule.dart';
import 'package:respira_mty/utils/air_quality_scale.dart';

/// Pure copy generator. Resolves localized title/body for an [AlertRule],
/// using [AppLocalizations] at the time of firing (locale-frozen).
///
/// Pulled out as a top-level utility so the background isolate can use it
/// without a [BuildContext]: load an [AppLocalizations] via
/// `AppLocalizations.delegate.load(Locale(...))` and pass it in.
class AlertCopy {
  const AlertCopy._();

  /// Returns the title for the alert, localized via [loc].
  static String title(AppLocalizations loc, AlertRule rule) {
    switch (rule.reason) {
      case AlertReason.crossingThreshold:
        return loc.alertEventTitleCrossing(categoryLabel(loc, rule.category));
      case AlertReason.worseningCategory:
        return loc.alertEventTitleWorsening(categoryLabel(loc, rule.category));
      case AlertReason.improvementBackToGood:
        return loc.alertEventTitleImprovement(rule.stationName);
    }
  }

  /// Returns the body for the alert, localized via [loc].
  static String body(AppLocalizations loc, AlertRule rule) {
    switch (rule.reason) {
      case AlertReason.crossingThreshold:
        return loc.alertEventBodyCrossing(
          rule.stationName,
          rule.dominantPollutant,
          formatValue(rule.value, rule.dominantPollutant),
          rule.unit,
        );
      case AlertReason.worseningCategory:
        return loc.alertEventBodyWorsening(
          rule.stationName,
          rule.dominantPollutant,
          formatValue(rule.value, rule.dominantPollutant),
          rule.unit,
        );
      case AlertReason.improvementBackToGood:
        return loc.alertEventBodyImprovement(rule.stationName);
    }
  }

  /// Maps a category to its localized status label (Mala/Muy Mala/etc).
  /// Used for the `{category}` placeholder in title strings.
  ///
  /// `good`, `acceptable`, `maintenance` are not expected to reach here in
  /// practice (the evaluator never emits crossing/worsening rules for them),
  /// but for safety we still return a sensible localized fallback rather than
  /// an empty string.
  static String categoryLabel(AppLocalizations loc, AirQualityCategory category) {
    switch (category) {
      case AirQualityCategory.bad:
        return loc.airQualityBad;
      case AirQualityCategory.veryBad:
        return loc.airQualityVeryBad;
      case AirQualityCategory.extremelyBad:
        return loc.airQualityExtremelyBad;
      case AirQualityCategory.good:
      case AirQualityCategory.acceptable:
      case AirQualityCategory.maintenance:
        // Fall back to the non-localized status text so the placeholder is
        // never empty. These branches should not be reached in practice.
        return AirQualityScale.getStatusForCategory(category);
    }
  }

  /// Formats a numeric value the way [DominantPollutant.displayValue] does
  /// (1 decimal for CO, 0 decimals for everything else).
  static String formatValue(double value, String pollutant) {
    if (pollutant == 'CO') return value.toStringAsFixed(1);
    return value.toStringAsFixed(0);
  }
}
