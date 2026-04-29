import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:respira_mty/l10n/app_localizations.dart';
import 'package:respira_mty/models/alert_event.dart';
import 'package:respira_mty/models/alert_rule.dart';
import 'package:respira_mty/services/alerts/alert_copy.dart';
import 'package:respira_mty/utils/air_quality_scale.dart';

/// Builds an [AlertRule] with sensible defaults for tests.
AlertRule _rule({
  AlertReason reason = AlertReason.crossingThreshold,
  AirQualityCategory category = AirQualityCategory.veryBad,
  String stationName = 'Centro',
  String pollutant = 'PM2.5',
  double value = 45.7,
  String unit = 'µg/m³',
  AirQualityCategory? previous,
}) => AlertRule(
  stationId: 'sta',
  stationName: stationName,
  category: category,
  previousCategory: previous,
  dominantPollutant: pollutant,
  value: value,
  unit: unit,
  reason: reason,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AlertCopy.formatValue', () {
    test('CO uses 1 decimal', () {
      expect(AlertCopy.formatValue(1.234, 'CO'), '1.2');
      expect(AlertCopy.formatValue(9.0, 'CO'), '9.0');
    });

    test('non-CO uses 0 decimals', () {
      expect(AlertCopy.formatValue(45.7, 'PM2.5'), '46');
      expect(AlertCopy.formatValue(45.4, 'PM2.5'), '45');
      expect(AlertCopy.formatValue(132.0, 'PM10'), '132');
      expect(AlertCopy.formatValue(99.5, 'O3'), '100');
    });
  });

  group('AlertCopy.categoryLabel', () {
    test('Spanish category labels', () async {
      final loc = await AppLocalizations.delegate.load(const Locale('es'));
      expect(
        AlertCopy.categoryLabel(loc, AirQualityCategory.bad),
        'Calidad Mala',
      );
      expect(
        AlertCopy.categoryLabel(loc, AirQualityCategory.veryBad),
        'Calidad Muy Mala',
      );
      expect(
        AlertCopy.categoryLabel(loc, AirQualityCategory.extremelyBad),
        'Calidad Extremadamente Mala',
      );
    });

    test('English category labels', () async {
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      expect(AlertCopy.categoryLabel(loc, AirQualityCategory.bad), 'Bad');
      expect(
        AlertCopy.categoryLabel(loc, AirQualityCategory.veryBad),
        'Very bad',
      );
      expect(
        AlertCopy.categoryLabel(loc, AirQualityCategory.extremelyBad),
        'Extremely bad',
      );
    });

    test('non-target categories fall back to the non-localized status text',
        () async {
      final loc = await AppLocalizations.delegate.load(const Locale('es'));
      // good / acceptable / maintenance shouldn't be reached for crossing or
      // worsening titles, but we don't want an empty placeholder if they are.
      expect(
        AlertCopy.categoryLabel(loc, AirQualityCategory.good),
        AirQualityScale.getStatusForCategory(AirQualityCategory.good),
      );
      expect(
        AlertCopy.categoryLabel(loc, AirQualityCategory.acceptable),
        AirQualityScale.getStatusForCategory(AirQualityCategory.acceptable),
      );
      expect(
        AlertCopy.categoryLabel(loc, AirQualityCategory.maintenance),
        AirQualityScale.getStatusForCategory(AirQualityCategory.maintenance),
      );
    });
  });

  group('AlertCopy.title', () {
    test('Spanish — crossingThreshold uses category label', () async {
      final loc = await AppLocalizations.delegate.load(const Locale('es'));
      final rule = _rule(
        reason: AlertReason.crossingThreshold,
        category: AirQualityCategory.veryBad,
      );
      expect(
        AlertCopy.title(loc, rule),
        'Calidad del aire: Calidad Muy Mala',
      );
    });

    test('Spanish — worseningCategory uses category label', () async {
      final loc = await AppLocalizations.delegate.load(const Locale('es'));
      final rule = _rule(
        reason: AlertReason.worseningCategory,
        category: AirQualityCategory.extremelyBad,
      );
      expect(
        AlertCopy.title(loc, rule),
        'Empeoró: ahora Calidad Extremadamente Mala',
      );
    });

    test('Spanish — improvementBackToGood uses station name', () async {
      final loc = await AppLocalizations.delegate.load(const Locale('es'));
      final rule = _rule(
        reason: AlertReason.improvementBackToGood,
        category: AirQualityCategory.good,
        stationName: 'Centro',
      );
      expect(
        AlertCopy.title(loc, rule),
        'Aire mejor en Centro',
      );
    });

    test('English — crossingThreshold', () async {
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      final rule = _rule(
        reason: AlertReason.crossingThreshold,
        category: AirQualityCategory.bad,
      );
      expect(AlertCopy.title(loc, rule), 'Air quality: Bad');
    });

    test('English — worseningCategory', () async {
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      final rule = _rule(
        reason: AlertReason.worseningCategory,
        category: AirQualityCategory.veryBad,
      );
      expect(AlertCopy.title(loc, rule), 'Worsened: now Very bad');
    });

    test('English — improvementBackToGood', () async {
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      final rule = _rule(
        reason: AlertReason.improvementBackToGood,
        stationName: 'Obispado',
      );
      expect(AlertCopy.title(loc, rule), 'Better air at Obispado');
    });
  });

  group('AlertCopy.body', () {
    test('Spanish — crossing body interpolates station/pollutant/value/unit',
        () async {
      final loc = await AppLocalizations.delegate.load(const Locale('es'));
      final rule = _rule(
        reason: AlertReason.crossingThreshold,
        stationName: 'Centro',
        pollutant: 'PM2.5',
        value: 45.7,
        unit: 'µg/m³',
      );
      expect(
        AlertCopy.body(loc, rule),
        'Centro: PM2.5 46 µg/m³. Limita actividades al aire libre.',
      );
    });

    test('Spanish — worsening body uses formatted value', () async {
      final loc = await AppLocalizations.delegate.load(const Locale('es'));
      final rule = _rule(
        reason: AlertReason.worseningCategory,
        stationName: 'San Bernabé',
        pollutant: 'CO',
        value: 12.4,
        unit: 'ppm',
      );
      // CO uses 1 decimal (formatValue branch).
      expect(
        AlertCopy.body(loc, rule),
        'San Bernabé: CO subió a 12.4 ppm.',
      );
    });

    test('Spanish — improvement body uses station only', () async {
      final loc = await AppLocalizations.delegate.load(const Locale('es'));
      final rule = _rule(
        reason: AlertReason.improvementBackToGood,
        stationName: 'Apodaca',
      );
      expect(
        AlertCopy.body(loc, rule),
        'Apodaca regresó a calidad buena.',
      );
    });

    test('English — crossing body', () async {
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      final rule = _rule(
        reason: AlertReason.crossingThreshold,
        stationName: 'Centro',
        pollutant: 'PM2.5',
        value: 45.7,
        unit: 'µg/m³',
      );
      expect(
        AlertCopy.body(loc, rule),
        'Centro: PM2.5 46 µg/m³. Limit outdoor activities.',
      );
    });

    test('English — worsening body', () async {
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      final rule = _rule(
        reason: AlertReason.worseningCategory,
        stationName: 'Centro',
        pollutant: 'PM10',
        value: 213.0,
        unit: 'µg/m³',
      );
      expect(
        AlertCopy.body(loc, rule),
        'Centro: PM10 rose to 213 µg/m³.',
      );
    });

    test('English — improvement body', () async {
      final loc = await AppLocalizations.delegate.load(const Locale('en'));
      final rule = _rule(
        reason: AlertReason.improvementBackToGood,
        stationName: 'Obispado',
      );
      expect(
        AlertCopy.body(loc, rule),
        'Obispado returned to good quality.',
      );
    });
  });
}
