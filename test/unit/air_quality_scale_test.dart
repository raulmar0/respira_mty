import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:respira_mty/utils/air_quality_scale.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AirQualityScale', () {
    test('returns a color for known parameter', () {
      final color = AirQualityScale.getColorForParameter('PM25', 12.0);
      expect(color, isA<Color>());
    });

    test('returns unit for PM25 and CO', () {
      expect(AirQualityScale.getUnitForParameter('PM25'), isNotEmpty);
      expect(AirQualityScale.getUnitForParameter('CO'), isNotEmpty);
    });

    test('color changes with value', () {
      final cGood = AirQualityScale.getColorForParameter('PM25', 5.0);
      final cBad = AirQualityScale.getColorForParameter('PM25', 200.0);
      expect(cGood != cBad, isTrue);
    });
  });
}
