import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/light_theme.dart';
import '../theme/dark_theme.dart';
import 'settings_provider.dart';

/// Provider that returns the current theme based on dark mode setting
final themeProvider = Provider<ThemeData>((ref) {
  final isDarkMode = ref.watch(darkModeProvider);
  return isDarkMode ? darkTheme : lightTheme;
});