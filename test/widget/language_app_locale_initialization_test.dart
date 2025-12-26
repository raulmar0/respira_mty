import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:respira_mty/l10n/app_localizations.dart';
import 'package:respira_mty/screens/settings_screen.dart';
import 'package:respira_mty/providers/settings_provider.dart';

void main() {
  testWidgets('App initializes with saved language from SharedPreferences', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'app_language': 'korean'});

    final testApp = ProviderScope(
      child: Consumer(
        builder: (context, ref, child) {
          return MaterialApp(
            locale: ref.watch(languageProvider).locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsScreen(),
          );
        },
      ),
    );

    await tester.pumpWidget(testApp);

    // Wait for the provider to initialize and UI to update (timeout 2s)
    final end = DateTime.now().add(const Duration(seconds: 2));
    while (DateTime.now().isBefore(end) && find.text('설정').evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.text('설정'), findsOneWidget);
  });
}
