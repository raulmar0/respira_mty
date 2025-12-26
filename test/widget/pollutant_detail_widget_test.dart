import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:respira_mty/screens/pollutant_detail_screen.dart';
import 'package:respira_mty/data/pollutants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PollutantDetailScreen widget', () {
    testWidgets('renders main card and sections in light theme', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PollutantDetailScreen(parameter: 'PM25M', value: 12.0, unit: 'µg/m³'),
      ));

      await tester.pumpAndSettle();

      // Main elements
      expect(find.text('PM2.5'), findsOneWidget);
      expect(find.text('µg/m³'), findsOneWidget);
      expect(find.text('Riesgos'), findsOneWidget);
      expect(find.text('Fuentes'), findsOneWidget);
      expect(find.text('Método de medición'), findsOneWidget);

      // Method present
      final key = 'PM25';
      final info = pollutantMap[key]!;
      expect(find.text(info.method.method), findsOneWidget);
    });

    testWidgets('renders correctly in dark theme', (WidgetTester tester) async {
      final darkTheme = ThemeData.dark().copyWith(cardColor: const Color(0xFF0F1724));
      await tester.pumpWidget(MaterialApp(
        theme: darkTheme,
        home: PollutantDetailScreen(parameter: 'PM25M', value: 12.0, unit: 'µg/m³'),
      ));

      await tester.pumpAndSettle();

      // Section headers and method still present
      expect(find.text('Riesgos'), findsOneWidget);
      expect(find.text('Fuentes'), findsOneWidget);
      expect(find.text('Método de medición'), findsOneWidget);

      // Ensure the main quality badge shows a text label
      expect(find.textContaining('Calidad'), findsOneWidget);
    });

    testWidgets('handles missing pollutant info gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PollutantDetailScreen(parameter: 'UNKNOWN', value: null, unit: ''),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Riesgos'), findsOneWidget);
      expect(find.text('Fuentes'), findsOneWidget);
      // It should display fallback info cards (generic text)
      expect(find.textContaining('Problemas Respiratorios'), findsOneWidget);
    });
  });
}
