import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_provider.dart';

/// Provider that returns the current theme mode
final themeModeProviderAlias = Provider<ThemeMode>((ref) {
  final themeModeAsync = ref.watch(themeModeProvider);
  return themeModeAsync.when(
    data: (option) => option.themeMode,
    loading: () => ThemeMode.system,
    error: (err, stack) => ThemeMode.system,
  );
});