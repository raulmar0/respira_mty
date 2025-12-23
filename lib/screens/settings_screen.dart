import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final isDarkMode = ref.watch(darkModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.iconTheme.color),
          onPressed: () {},
        ),
        title: Text(
          "Ajustes",
          style: theme.appBarTheme.titleTextStyle,
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            // 2. Sección Notificaciones
            const _SectionHeader(title: "NOTIFICACIONES"),
            _SettingsGroup(
              children: [
                _SettingsTile(
                  icon: Icons.warning_amber_rounded,
                  iconColor: Colors.redAccent,
                  iconBg: const Color(0xFFFDE8E8),
                  title: "Alertas Críticas",
                  subtitle: "Notificar cuando el aire sea peligroso",
                  trailing: Switch(
                    value: true,
                    activeThumbColor: Colors.white,
                    activeTrackColor: const Color(0xFF5CE57E),
                    onChanged: (v) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // 3. Sección Visualización
            const _SectionHeader(title: "VISUALIZACIÓN"),
            _SettingsGroup(
              children: [

                _SettingsTile(
                  icon: Icons.language,
                  iconColor: Colors.blue,
                  iconBg: const Color(0xFFE3F2FD),
                  title: "Idioma",
                  trailingText: currentLang.displayName,
                  showArrow: true,
                  onTap: () async {
                    final chosen = await showDialog<AppLanguage>(
                      context: context,
                      builder: (ctx) => SimpleDialog(
                        title: const Text('Idioma'),
                        children: [
                          SimpleDialogOption(
                            onPressed: () => Navigator.pop(ctx, AppLanguage.spanish),
                            child: const Text('Español'),
                          ),
                          SimpleDialogOption(
                            onPressed: () => Navigator.pop(ctx, AppLanguage.english),
                            child: const Text('English'),
                          ),
                        ],
                      ),
                    );

                    if (chosen != null) {
                      ref.read(languageProvider.notifier).setLanguage(chosen);
                    }
                  },
                ),

                _SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  iconColor: Colors.blueGrey,
                  iconBg: const Color(0xFFECEFF1),
                  title: "Modo Oscuro",
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (value) {
                      ref.read(darkModeProvider.notifier).toggle();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // 4. Sección Información
            const _SectionHeader(title: "INFORMACIÓN"),
            const _SettingsGroup(
              children: [
                _SettingsTile(
                  title: "Política de Privacidad",
                  showArrow: true,
                ),
                _CustomDivider(),
                _SettingsTile(
                  title: "Acerca de la App",
                  showArrow: true,
                ),
              ],
            ),
            const SizedBox(height: 30),



            // 6. Footer Versión
            Center(
              child: Column(
                children: [
                  Text("Versión 1.0.2", style: theme.textTheme.labelSmall),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud, size: 12, color: theme.iconTheme.color?.withOpacity(0.6)),
                      const SizedBox(width: 4),
                      Text("Datos provistos por SIMA N.L.", style: theme.textTheme.labelSmall),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS AUXILIARES PARA LIMPIEZA DEL CÓDIGO ---


class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBg;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final String? trailingText;
  final bool showArrow;
  final VoidCallback? onTap;

  const _SettingsTile({
    this.icon,
    this.iconColor,
    this.iconBg,
    required this.title,
    this.subtitle,
    this.trailing,
    this.trailingText,
    this.showArrow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.labelLarge),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(subtitle!, style: theme.textTheme.bodySmall),
                    ),
                ],
              ),
            ),
            if (trailingText != null)
              Text(trailingText!, style: theme.textTheme.labelMedium),
            if (trailing != null) trailing!,
            if (showArrow) ...[
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, size: 20, color: theme.dividerTheme.color),
            ]
          ],
        ),
      ),
    );
  }
}

class _CustomDivider extends StatelessWidget {
  const _CustomDivider();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Divider(height: 1, thickness: 0.5, color: theme.dividerTheme.color, indent: 60, endIndent: 0);
  }
}
