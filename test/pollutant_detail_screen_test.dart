import 'package:flutter/material.dart';
import 'package:respira_mty/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:respira_mty/screens/pollutant_detail_screen.dart';

void main() {
  testWidgets('Pollutant detail shows measurement, risks and sources for PM10', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: PollutantDetailScreen(parameter: 'PM10', value: 60, unit: 'µg/m³'),
    ));

    await tester.pumpAndSettle();

    final loc = AppLocalizations.of(tester.element(find.byType(PollutantDetailScreen)))!;
    expect(find.text(loc.measurementMethod), findsOneWidget);
    expect(find.text(loc.shortTerm), findsOneWidget);
    expect(find.text(loc.sourcesTitle), findsOneWidget);
    // Check for a known source or risk item from the data
    expect(find.textContaining('Actividades de construcción'), findsOneWidget);

    // Main card: numeric value, unit, abbreviation and quality badge
    expect(find.text('60'), findsOneWidget);
    expect(find.text('µg/m³'), findsOneWidget);
    expect(find.text('PM10'), findsOneWidget);
    expect(find.textContaining('Aumento de morbimortalidad respiratoria'), findsOneWidget);
    // Badge text
    expect(find.textContaining('Calidad'), findsOneWidget);
  });

  testWidgets('share button is present in PollutantDetailScreen', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: PollutantDetailScreen(parameter: 'PM10', value: 60, unit: 'µg/m³'),
    ));

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.share_outlined), findsOneWidget);
  });
}
