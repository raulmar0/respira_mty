import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language choices for the app
enum AppLanguage { spanish, english }

extension AppLanguageExt on AppLanguage {
  String get displayName {
    switch (this) {
      case AppLanguage.spanish:
        return 'Español';
      case AppLanguage.english:
        return 'English';
    }
  }
}

/// Notifier-based provider for language (compatible with project's Notifier API)
class LanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() => AppLanguage.spanish;

  void setLanguage(AppLanguage lang) => state = lang;
}

final languageProvider = NotifierProvider<LanguageNotifier, AppLanguage>(LanguageNotifier.new);

/// Theme mode options
enum ThemeModeOption { light, dark, system }

extension ThemeModeOptionExt on ThemeModeOption {
  String get displayName {
    switch (this) {
      case ThemeModeOption.light:
        return 'Claro';
      case ThemeModeOption.dark:
        return 'Oscuro';
      case ThemeModeOption.system:
        return 'Sistema';
    }
  }

  ThemeMode get themeMode {
    switch (this) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.system:
        return ThemeMode.system;
    }
  }
}

/// Notifier-based provider for theme mode with persistence
class ThemeModeNotifier extends AsyncNotifier<ThemeModeOption> {
  static const String _key = 'theme_mode';

  @override
  Future<ThemeModeOption> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null) {
      return ThemeModeOption.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => ThemeModeOption.system,
      );
    }
    return ThemeModeOption.system; // Default to system
  }

  Future<void> setThemeMode(ThemeModeOption mode) async {
    state = AsyncValue.data(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}

final themeModeProvider = AsyncNotifierProvider<ThemeModeNotifier, ThemeModeOption>(ThemeModeNotifier.new);

/// Provider for SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});
class CriticalAlertsNotifier extends Notifier<bool> {
  @override
  bool build() => false; // Default: disabled

  void setEnabled(bool enabled) => state = enabled;

  void toggle() => state = !state;
}

final criticalAlertsProvider = NotifierProvider<CriticalAlertsNotifier, bool>(CriticalAlertsNotifier.new);