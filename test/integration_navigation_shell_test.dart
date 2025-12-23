import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:respira_mty/models/station.dart';
import 'package:respira_mty/providers/station_provider.dart';
import 'package:respira_mty/screens/main_shell.dart';
import 'package:respira_mty/widgets/station_card.dart';

void main() {
  testWidgets('navigation within shell keeps bottom navigation visible', (tester) async {
    final station = Station(
      id: 's1',
      apiCode: 'S1',
      name: 'MiMunicipio, Zona',
      latitude: 25.0,
      longitude: -100.0,
      pm25: 12.0,
      pm10: 20.0,
      o3: 10.0,
      no2: 5.0,
      so2: 2.0,
      co: 0.4,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          airQualityProvider.overrideWith((ref) async => [station]),
        ],
        child: const MaterialApp(home: MainShell()),
      ),
    );

    await tester.pumpAndSettle();

    // Ensure Scaffold has a bottomNavigationBar
    final scaffoldFinder = find.byWidgetPredicate((w) => w is Scaffold && (w as Scaffold).bottomNavigationBar != null);
    expect(scaffoldFinder, findsOneWidget);

    // Tap 'List' tab to show list
    await tester.tap(find.text('List'));
    await tester.pumpAndSettle();

    // Station is visible in list
    expect(find.text('MiMunicipio'), findsWidgets);

    // Tap station card
    await tester.tap(find.byType(StationCard).first);
    await tester.pumpAndSettle();

    // Detail header shows municipality
    expect(find.text('MiMunicipio'), findsWidgets);
  });
}
