import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:respira_mty/providers/settings_provider.dart';

void main() {
  test('LanguageNotifier loads saved language from SharedPreferences', () async {
    // Simulate previously saved language
    SharedPreferences.setMockInitialValues({'app_language': 'korean'});

    final container = ProviderContainer();
    try {
      // Wait until provider updates (notifier loads asynchronously)
      final end = DateTime.now().add(const Duration(seconds: 1));
      while (DateTime.now().isBefore(end)) {
        if (container.read(languageProvider) == AppLanguage.korean) break;
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }

      final lang = container.read(languageProvider);
      expect(lang, AppLanguage.korean);
    } finally {
      container.dispose();
    }
  });

  test('LanguageNotifier saves language to SharedPreferences when setLanguage is called', () async {
    SharedPreferences.setMockInitialValues({});

    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initially default
    expect(container.read(languageProvider), AppLanguage.spanish);

    // Set language (setLanguage performs async saving internally)
    container.read(languageProvider.notifier).setLanguage(AppLanguage.french);

    // wait for async write
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_language'), 'french');
  });
}
