import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Light theme for the app
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF4CAF50),
    brightness: Brightness.light,
  ),
  useMaterial3: true,
  fontFamily: 'Spline Sans',

  // Scaffold and background
  scaffoldBackgroundColor: AppColors.backgroundGray,

  // AppBar theme
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColors.textPrimary),
    titleTextStyle: TextStyle(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.bold,
      fontSize: 24,
      fontFamily: 'Spline Sans',
    ),
  ),

  // Card theme
  cardTheme: const CardThemeData(
    color: Colors.white,
    elevation: 0,
  ),

  // Text themes
  textTheme: const TextTheme(
    // Headlines
    headlineLarge: TextStyle(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.bold,
      fontSize: 32,
      fontFamily: 'Spline Sans',
    ),
    headlineMedium: TextStyle(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.bold,
      fontSize: 24,
      fontFamily: 'Spline Sans',
    ),
    headlineSmall: TextStyle(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
      fontSize: 20,
      fontFamily: 'Spline Sans',
    ),

    // Body text
    bodyLarge: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 16,
      fontFamily: 'Spline Sans',
    ),
    bodyMedium: TextStyle(
      color: AppColors.textSecondary,
      fontSize: 14,
      fontFamily: 'Spline Sans',
    ),
    bodySmall: TextStyle(
      color: AppColors.textSecondary,
      fontSize: 12,
      fontFamily: 'Spline Sans',
    ),

    // Labels
    labelLarge: TextStyle(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
      fontSize: 14,
      fontFamily: 'Spline Sans',
    ),
    labelMedium: TextStyle(
      color: AppColors.textSecondary,
      fontSize: 12,
      fontFamily: 'Spline Sans',
    ),
    labelSmall: TextStyle(
      color: AppColors.textSecondary,
      fontSize: 11,
      fontFamily: 'Spline Sans',
    ),
  ),

  // Icon theme
  iconTheme: const IconThemeData(
    color: AppColors.textPrimary,
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
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
    ),
    labelStyle: TextStyle(
      color: AppColors.textSecondary,
      fontFamily: 'Spline Sans',
    ),
    hintStyle: TextStyle(
      color: AppColors.textSecondary.withOpacity(0.7),
      fontFamily: 'Spline Sans',
    ),
  ),

  // Switch theme
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return Colors.white;
      }
      return Colors.grey[400];
    }),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFF4CAF50);
      }
      return Colors.grey[300];
    }),
  ),

  // Divider theme
  dividerTheme: DividerThemeData(
    color: Colors.grey[200],
    thickness: 0.5,
  ),

  // Bottom sheet theme
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
  ),
);