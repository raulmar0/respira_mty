import 'package:flutter_test/flutter_test.dart';
import 'package:respira_mty/data/pollutants.dart';

void main() {
  group('Pollutant data', () {
    test('pollutantMap contains expected keys', () {
      expect(pollutantMap.isNotEmpty, true);
      // Expect some common keys
      expect(pollutantMap.containsKey('PM25'), true);
      expect(pollutantMap.containsKey('PM10'), true);
      expect(pollutantMap.containsKey('O3'), true);
      expect(pollutantMap.containsKey('NO2'), true);
      expect(pollutantMap.containsKey('SO2'), true);
      expect(pollutantMap.containsKey('CO'), true);
    });

    test('each PollutantInfo includes method, sources and risks', () {
      for (final entry in pollutantMap.entries) {
        final info = entry.value;
        expect(info.method, isNotNull);
        expect(info.sources, isNotNull);
        expect(info.risks, isNotNull);
      }
    });
  });
}
