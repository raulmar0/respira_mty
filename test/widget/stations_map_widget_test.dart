import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:respira_mty/screens/stations_map_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StationsMapScreen widget', () {
    testWidgets('renders header and filter chips', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: StationsMapScreen())));
      await tester.pumpAndSettle();

      expect(find.text('Mapa de Estaciones'), findsOneWidget);
      expect(find.text('All Stations'), findsOneWidget);
      expect(find.text('Good'), findsOneWidget);
      expect(find.text('Moderate'), findsOneWidget);
      expect(find.text('Unhealthy'), findsOneWidget);
    });

    testWidgets('shows map control buttons', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: StationsMapScreen())));
      await tester.pumpAndSettle();

      // Look for + and - icons
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
    });
  });
}
