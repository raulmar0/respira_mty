import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:respira_mty/l10n/app_localizations.dart';
import 'package:respira_mty/services/alerts/background_callback.dart';
import 'package:respira_mty/services/alerts/notification_service.dart';
import 'package:workmanager/workmanager.dart';
import 'screens/main_shell.dart';
import 'providers/theme_provider.dart';
import 'providers/settings_provider.dart';
import 'theme/light_theme.dart';
import 'theme/dark_theme.dart';
import 'zoom_splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Notification plugin (channels, timezone, tap handler).
  await NotificationService.instance.initialize();

  // Background polling. iOS honors only opportunistically; Android honors
  // the 15-minute frequency on most OEMs.
  await Workmanager().initialize(alertBackgroundCallback);
  await Workmanager().registerPeriodicTask(
    'respira-alert-poll',
    alertPollTaskName,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProviderAlias);
    final currentLang = ref.watch(languageProvider);

    return MaterialApp(
      title: AppLocalizations.of(context)?.appTitle ?? 'Respira MTY',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      locale: currentLang.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        Locale('ko'),
      ],
      home: ZoomSplashScreen(),
      routes: {
        '/home': (context) => const MainShell(),
      },
    );
  }
}
