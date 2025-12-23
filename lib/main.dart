import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/main_shell.dart';
import 'providers/theme_provider.dart';
import 'zoom_splash_screen.dart';
import 'screens/station_detail_screen.dart';

void main() {
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
    final theme = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Respira MTY',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: ZoomSplashScreen(),
      routes: {
        '/home': (context) => const MainShell(),
        '/stationDetail': (context) => const StationDetailScreenLight(),
      },
    );
  }
}
