import 'package:flutter/material.dart';

/// Dark theme for the app
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF4CAF50),
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
  fontFamily: 'Spline Sans',

  // Scaffold and background - dark backgrounds
  scaffoldBackgroundColor: const Color(0xFF121212), // Dark gray background

  // AppBar theme
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 24,
      fontFamily: 'Spline Sans',
    ),
  ),

  // Card theme
  cardTheme: const CardThemeData(
    color: Color(0xFF1E1E1E), // Dark card background
    elevation: 0,
  ),

  // Text themes - light text on dark background
  textTheme: const TextTheme(
    // Headlines
    headlineLarge: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 32,
      fontFamily: 'Spline Sans',
    ),
    headlineMedium: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 24,
      fontFamily: 'Spline Sans',
    ),
    headlineSmall: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      fontSize: 20,
      fontFamily: 'Spline Sans',
    ),

    // Body text
    bodyLarge: TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontFamily: 'Spline Sans',
    ),
    bodyMedium: TextStyle(
      color: Color(0xFFB3B3B3), // Light gray for secondary text
      fontSize: 14,
      fontFamily: 'Spline Sans',
    ),
    bodySmall: TextStyle(
      color: Color(0xFFB3B3B3), // Light gray for secondary text
      fontSize: 12,
      fontFamily: 'Spline Sans',
    ),

    // Labels
    labelLarge: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      fontSize: 14,
      fontFamily: 'Spline Sans',
    ),
    labelMedium: TextStyle(
      color: Color(0xFFB3B3B3), // Light gray for secondary text
      fontSize: 12,
      fontFamily: 'Spline Sans',
    ),
    labelSmall: TextStyle(
      color: Color(0xFFB3B3B3), // Light gray for secondary text
      fontSize: 11,
      fontFamily: 'Spline Sans',
    ),
  ),

  // Icon theme
  iconTheme: const IconThemeData(
    color: Colors.white,
    size: 24,
  ),

  // Button themes
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4CAF50),
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        fontFamily: 'Spline Sans',
      ),
    ),
  ),

  // Input decoration theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2A2A2A), // Dark input background
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF404040)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF404040)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
    ),
    labelStyle: TextStyle(
      color: const Color(0xFFB3B3B3), // Light gray labels
      fontFamily: 'Spline Sans',
    ),
    hintStyle: TextStyle(
      color: const Color(0xFF808080), // Medium gray hints
      fontFamily: 'Spline Sans',
    ),
  ),

  // Switch theme
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return Colors.white;
      }
      return const Color(0xFF606060);
    }),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFF4CAF50);
      }
      return const Color(0xFF404040);
    }),
  ),

  // Divider theme
  dividerTheme: const DividerThemeData(
    color: Color(0xFF404040),
    thickness: 0.5,
  ),

  // Bottom sheet theme
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color(0xFF1E1E1E),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
  ),
);