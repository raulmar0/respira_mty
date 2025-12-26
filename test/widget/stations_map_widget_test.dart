import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:respira_mty/screens/stations_map_screen.dart';
import 'package:respira_mty/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StationsMapScreen widget', () {
    testWidgets('renders header and filter chips', (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const StationsMapScreen(),
      )));
      await tester.pumpAndSettle();

      final loc = AppLocalizations.of(tester.element(find.byType(StationsMapScreen)))!;
      expect(find.text(loc.stationsMapTitle), findsOneWidget);
      expect(find.text(loc.filterAll), findsOneWidget);
      expect(find.text(loc.filterGood), findsOneWidget);
      expect(find.text(loc.filterModerate), findsOneWidget);
      expect(find.text(loc.filterUnhealthy), findsOneWidget);
    });

    testWidgets('shows map control buttons', (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const StationsMapScreen(),
      )));
      await tester.pumpAndSettle();

      // Look for + and - icons
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
    });

    testWidgets('filter chips keep color across locale changes', (WidgetTester tester) async {
      // English
      await tester.pumpWidget(ProviderScope(child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const StationsMapScreen(),
      )));
      await tester.pumpAndSettle();
      final locEn = AppLocalizations.of(tester.element(find.byType(StationsMapScreen)))!;
      final containerEn = tester.widgetList<Container>(find.ancestor(of: find.text(locEn.filterGood), matching: find.byType(Container))).first;
      final colorEn = (containerEn.decoration as BoxDecoration).color;

      // Spanish
      await tester.pumpWidget(ProviderScope(child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const StationsMapScreen(),
      )));
      await tester.pumpAndSettle();
      final locEs = AppLocalizations.of(tester.element(find.byType(StationsMapScreen)))!;
      final containerEs = tester.widgetList<Container>(find.ancestor(of: find.text(locEs.filterGood), matching: find.byType(Container))).first;
      final colorEs = (containerEs.decoration as BoxDecoration).color;

      expect(colorEn, equals(colorEs));
    });
  });
}
