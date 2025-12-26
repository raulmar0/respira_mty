import 'package:flutter/material.dart';
import 'package:respira_mty/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:respira_mty/screens/pollutant_detail_screen.dart';

void main() {
  final updateGoldens = bool.fromEnvironment('updateGoldens');

  group('PollutantDetail golden', () {
    testWidgets('light theme golden', (tester) async {
      if (!updateGoldens) return;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: PollutantDetailScreen(parameter: 'PM25M', value: 12.0, unit: 'µg/m³'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(find.byType(PollutantDetailScreen), matchesGoldenFile('test/goldens/pollutant_detail_light.png'));
    });

    testWidgets('dark theme golden', (tester) async {
      if (!updateGoldens) return;

      final darkTheme = ThemeData.dark().copyWith(cardColor: const Color(0xFF0F1724));
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('es'),
            theme: darkTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PollutantDetailScreen(parameter: 'PM25M', value: 12.0, unit: 'µg/m³'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(find.byType(PollutantDetailScreen), matchesGoldenFile('test/goldens/pollutant_detail_dark.png'));
    });
  });
}
