import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'utils/app_colors.dart';
import 'screens/main_shell.dart';
import 'screens/stations_list_screen.dart';
import 'zoom_splash_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Respira MTY',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
        useMaterial3: true,
        fontFamily: 'Spline Sans',
        scaffoldBackgroundColor: AppColors.backgroundGray,
      ),
      home: ZoomSplashScreen(),
      routes: {
        '/home': (context) => const MainShell(),
      },
    );
  }
}
