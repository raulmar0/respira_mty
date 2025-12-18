// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:respira_mty/models/station.dart';
import 'package:respira_mty/providers/station_provider.dart';
import 'package:respira_mty/screens/stations_list_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Stations list loads and favorites toggle works', (
    WidgetTester tester,
  ) async {
    const station = Station(
      id: '1',
      apiCode: 'MTY-01',
      name: 'Centro',
      status: 'OK',
      aqi: 42,
      pm25: 12.3,
      pm10: 20.1,
      o3: 10,
      no2: 5,
      so2: 2,
      co: 0.4,
      latitude: 25.6866,
      longitude: -100.3161,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          airQualityProvider.overrideWith((ref) async => [station]),
        ],
        child: const MaterialApp(home: StationsListScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Estaciones'), findsOneWidget);
    expect(find.text('Centro'), findsOneWidget);

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pump();
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });
}
