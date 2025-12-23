import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

/// Bottom sheet para selección de idioma.
/// Usa el provider `languageProvider` para leer/guardar la selección.
class LanguageSelectionSheet extends ConsumerStatefulWidget {
  const LanguageSelectionSheet({super.key});

  @override
  ConsumerState<LanguageSelectionSheet> createState() => _LanguageSelectionSheetState();
}

class _LanguageSelectionSheetState extends ConsumerState<LanguageSelectionSheet> {
  // 0: Español, 1: English, 2: (opcional) Français
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    final current = ref.read(languageProvider);
    _selectedIndex = current == AppLanguage.spanish ? 0 : 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color activeColor = theme.colorScheme.primary;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color ?? theme.dialogBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.dividerTheme.color ?? Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              "Seleccionar idioma",
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Elige el idioma para la interfaz de la aplicación.",
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.9)),
            ),
            const SizedBox(height: 24),

            _buildOption(0, "Español", "🇲🇽", activeColor, theme),
            const SizedBox(height: 12),
            _buildOption(1, "English", "🇺🇸", activeColor, theme),
            // Mantenemos la opción Francés visualmente por si se quiere añadir soporte,
            // al guardar mapearemos 2 -> English para evitar estados inválidos.
            const SizedBox(height: 12),
            _buildOption(2, "Français", "🇫🇷", activeColor, theme),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Map index to AppLanguage (2 -> english fallback)
                  final lang = _selectedIndex == 0 ? AppLanguage.spanish : AppLanguage.english;
                  ref.read(languageProvider.notifier).setLanguage(lang);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Guardar cambios",
                  style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int index, String text, String flagEmoji, Color activeColor, ThemeData theme) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.08) : theme.cardTheme.color ?? Colors.white,
          border: Border.all(
            color: isSelected ? activeColor : (theme.dividerTheme.color ?? Colors.grey.shade300),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(flagEmoji, style: TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Text(
              text,
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeColor,
                ),
                child: const Icon(Icons.check, size: 14, color: Colors.white),
              )
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.dividerTheme.color ?? Colors.grey.shade400, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
