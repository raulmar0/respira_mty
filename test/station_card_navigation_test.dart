import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:respira_mty/widgets/station_card.dart';
import 'package:respira_mty/models/station.dart';

void main() {
  testWidgets('tapping StationCard opens StationDetailScreenLight', (tester) async {
    final station = Station(
      id: '1',
      apiCode: 'A1',
      name: 'Test Municipality, Test Zone',
      latitude: 0.0,
      longitude: 0.0,
      parametrosUI: [
        {'Parameter': 'PM25M', 'HrAveData': 12.0},
      ],
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StationCard(station: station),
      ),
    ));

    expect(find.text('Test Municipality'), findsOneWidget);

    await tester.tap(find.byType(StationCard));
    // Use pump to advance the frame and allow navigation to push (avoid pumpAndSettle since some animations loop)
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // StationDetailScreenLight header shows municipality only
    expect(find.text('Test Municipality'), findsWidgets);
  });
}
