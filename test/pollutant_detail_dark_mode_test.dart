import 'package:flutter/material.dart';
import 'package:respira_mty/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:respira_mty/screens/pollutant_detail_screen.dart';

void main() {
  testWidgets('PollutantDetailScreen builds in dark theme', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        theme: ThemeData.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: PollutantDetailScreen(parameter: 'PM10', value: 60.0, unit: 'µg/m³')),
      ),
    );

    await tester.pumpAndSettle();

    // Verify main elements exist under dark theme
    expect(find.text('PM10'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);
    expect(find.textContaining('Calidad'), findsOneWidget);

    // Verify the main card uses dark card color when in dark theme
    final expectedCardColor = const Color(0xFF0F1724);
    final cardFinder = find.byWidgetPredicate((w) {
      if (w is Container && w.decoration is BoxDecoration) {
        final d = w.decoration as BoxDecoration;
        if (d.color == expectedCardColor) {
          if (d.borderRadius is BorderRadius) {
            final br = d.borderRadius as BorderRadius;
            return br.topLeft.x == 32.0;
          }
        }
      }
      return false;
    });

    expect(cardFinder, findsOneWidget);
  });
}
