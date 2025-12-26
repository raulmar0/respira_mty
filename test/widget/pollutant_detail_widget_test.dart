import 'package:flutter/material.dart';
import 'package:respira_mty/l10n/app_localizations.dart';
import 'package:respira_mty/l10n/app_localizations_ext.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:respira_mty/screens/pollutant_detail_screen.dart';
import 'package:respira_mty/data/pollutants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PollutantDetailScreen widget', () {
    testWidgets('renders main card and sections in light theme', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PollutantDetailScreen(parameter: 'PM25M', value: 12.0, unit: 'µg/m³'),
      ));

      await tester.pumpAndSettle();

      // Main elements
      final loc = AppLocalizations.of(tester.element(find.byType(PollutantDetailScreen)))!;
      expect(find.text('PM2.5'), findsOneWidget);
      expect(find.text('µg/m³'), findsOneWidget);
      expect(find.text(loc.risksTitle), findsOneWidget);
      expect(find.text(loc.sourcesTitle), findsOneWidget);
      expect(find.text(loc.measurementMethod), findsOneWidget);

      // Method present (localized)
      final key = 'PM25';
      final info = pollutantMap[key]!;
      final methodLabel = AppLocalizations.of(tester.element(find.byType(PollutantDetailScreen)))!.translateKey(info.method.methodKey);
      expect(find.text(methodLabel), findsOneWidget);
    });

    testWidgets('renders correctly in dark theme', (WidgetTester tester) async {
      final darkTheme = ThemeData.dark().copyWith(cardColor: const Color(0xFF0F1724));
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('es'),
        theme: darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
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

    testWidgets('renders O3 localized method, sources and risks', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PollutantDetailScreen(parameter: 'O3', value: 10.0, unit: 'ppb'),
      ));

      await tester.pumpAndSettle();

      final loc = AppLocalizations.of(tester.element(find.byType(PollutantDetailScreen)))!;
      final key = 'O3';
      final info = pollutantMap[key]!;

      final methodLabel = loc.translateKey(info.method.methodKey);
      // It should not use the generic fallback
      expect(methodLabel, isNot(loc.genericPollutantInfo));
      expect(find.text(methodLabel), findsOneWidget);

      // Source localized
      final sourceLabel = loc.translateKey(info.sources.first.textKey);
      expect(sourceLabel, isNot(loc.genericPollutantInfo));
      expect(find.text(sourceLabel), findsOneWidget);

      // At least one risk localized (short-term)
      final riskLabel = loc.translateKey(info.risks.shortTerm.first.textKey);
      expect(riskLabel, isNot(loc.genericPollutantInfo));
      expect(find.text(riskLabel), findsOneWidget);

      // Description specific to O3 should be present
      expect(find.text(loc.o3_desc), findsOneWidget);
    });

    testWidgets('handles missing pollutant info gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
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
