import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:respira_mty/models/station.dart';
import 'package:respira_mty/providers/station_provider.dart';
import 'package:respira_mty/screens/main_shell.dart';

void main() {
  testWidgets('navigate from list to pollutant detail', (tester) async {
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
      parametrosUI: [
        {'Parameter': 'PM25', 'HrAveData': 12.0},
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          airQualityProvider.overrideWith((ref) async => [station]),
        ],
        child: const MaterialApp(home: MainShell()),
      ),
    );

    // Advance frames
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Tap 'List' tab to show list
    await tester.tap(find.text('List'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Station is visible in list
    expect(find.text('MiMunicipio'), findsWidgets);

    // Tap station card
    await tester.tap(find.text('MiMunicipio').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Pollutant card present (e.g., Partículas PM2.5)
    expect(find.textContaining('PM2.5'), findsWidgets);

    // Tap a pollutant card to open detail
    await tester.tap(find.textContaining('PM2.5').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Pollutant detail header
    expect(find.textContaining('Detalle'), findsOneWidget);
    expect(find.textContaining('PM2.5'), findsOneWidget);
  });
}
