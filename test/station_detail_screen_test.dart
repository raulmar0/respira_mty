import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:respira_mty/screens/station_detail_screen.dart';
import 'package:respira_mty/models/station.dart';
import 'package:respira_mty/utils/air_quality_scale.dart';
import 'package:respira_mty/l10n/app_localizations.dart';

void main() {

Widget makeTestable(Station station) => MaterialApp(
  locale: const Locale('es'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales, 
        home: Scaffold(
          body: StationDetailScreenLight(station: station),
        ),
      );

  testWidgets('toggle switches between Contaminantes and Clima', (tester) async {
    final station = Station(
      id: '1',
      apiCode: 'A1',
      name: 'Municipio, Zona',
      latitude: 0.0,
      longitude: 0.0,
      parametrosUI: [
        {'Parameter': 'PM25M', 'HrAveData': 12.0},
      ],
    );

    await tester.pumpWidget(makeTestable(station));

    final loc = AppLocalizations.of(tester.element(find.byType(StationDetailScreenLight)))!;

    // Initially show contaminants
    expect(find.text(loc.pm2_5), findsOneWidget);

    // Tap Clima
    await tester.tap(find.text(loc.tabWeather));
    await tester.pumpAndSettle();

    // The embedded weather section should be visible
    expect(find.text(loc.temperatureNow), findsOneWidget);

    // Tap Contaminantes
    await tester.tap(find.text(loc.tabPollutants));
    await tester.pumpAndSettle();

    expect(find.text(loc.pm2_5), findsOneWidget);
  });

  testWidgets('zoom buttons change internal zoom state', (tester) async {
    final station = Station(
      id: '2',
      apiCode: 'A2',
      name: 'Municipio 2, Zona',
      latitude: 10.0,
      longitude: 10.0,
      parametrosUI: [],
    );

    await tester.pumpWidget(makeTestable(station));

    // Access state to read _zoom
    final state = tester.state(find.byType(StationDetailScreenLight)) as dynamic;
    expect(state.currentZoom, 13.0);

    // Tap zoom in
    await tester.tap(find.byKey(const Key('zoom_in')));
    await tester.pumpAndSettle();
    expect(state.currentZoom, greaterThan(13.0));

    // Tap zoom out
    await tester.tap(find.byKey(const Key('zoom_out')));
    await tester.pumpAndSettle();
    expect(state.currentZoom, lessThanOrEqualTo(13.0));
  });

  testWidgets('shows marker icon and status badge, and pollutant color', (tester) async {
    final station = Station(
      id: '3',
      apiCode: 'A3',
      name: 'Municipio 3, Zona',
      latitude: 20.0,
      longitude: 20.0,
      parametrosUI: [
        {'Parameter': 'PM25M', 'HrAveData': 55.0}, // should produce a color
      ],
    );

    await tester.pumpWidget(makeTestable(station));
    await tester.pumpAndSettle();

    // Marker icon exists
    expect(find.byIcon(Icons.location_on), findsWidgets);

    // Badge shows status text
    expect(find.text(station.status), findsOneWidget);

    // Pollutant full name
    expect(find.text('Partículas PM2.5'), findsOneWidget);

    // Indicator color - compare to AirQualityScale expected color
    final expected = AirQualityScale.getColorForParameter('PM25M', 55.0);
    final indicatorFinder = find.byWidgetPredicate((w) {
      if (w is Container && w.decoration is BoxDecoration) {
        final d = w.decoration as BoxDecoration;
        return d.shape == BoxShape.circle && d.color == expected;
      }
      return false;
    });

    expect(indicatorFinder, findsOneWidget);
  });
}
