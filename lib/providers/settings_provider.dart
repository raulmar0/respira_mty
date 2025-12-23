import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Notifier-based provider for dark mode
class DarkModeNotifier extends Notifier<bool> {
  @override
  bool build() => false; // Default to light mode

  void toggle() => state = !state;
}

final darkModeProvider = NotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);