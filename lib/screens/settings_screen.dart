import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../widgets/language_selection_sheet.dart';
import 'package:respira_mty/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final themeModeAsync = ref.watch(themeModeProvider);
    final isCriticalEnabled = ref.watch(criticalAlertsProvider);
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
          AppLocalizations.of(context)!.settingsTitle,
          style: theme.appBarTheme.titleTextStyle,
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: themeModeAsync.when(
        data: (themeModeOption) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              // 2. Sección Notificaciones
              _SectionHeader(title: AppLocalizations.of(context)!.notificationsHeader),
              _SettingsGroup(
                children: [
                  _SettingsTile(
                    icon: Icons.warning_amber_rounded,
                    iconColor: Colors.redAccent,
                    iconBg: const Color(0xFFFDE8E8),
                    title: AppLocalizations.of(context)!.criticalAlertsTitle,
                    subtitle: AppLocalizations.of(context)!.criticalAlertsSubtitle,
                    trailing: Switch(
                      value: isCriticalEnabled,
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFF5CE57E),
                      onChanged: (v) {
                        ref.read(criticalAlertsProvider.notifier).setEnabled(v);
                        final messenger = ScaffoldMessenger.of(context);
                        messenger.showSnackBar(
                          SnackBar(content: Text(v ? AppLocalizations.of(context)!.alertsEnabled : AppLocalizations.of(context)!.alertsDisabled)),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // 3. Sección Visualización
              _SectionHeader(title: AppLocalizations.of(context)!.visualizationHeader),
              _SettingsGroup(
                children: [

                  _SettingsTile(
                    icon: Icons.language,
                    iconColor: Colors.blue,
                    iconBg: const Color(0xFFE3F2FD),
                    title: AppLocalizations.of(context)!.languageTitle,
                    trailingText: currentLang.displayName,
                    showArrow: true,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => const LanguageSelectionSheet(),
                      );
                    },
                  ),

                  _SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    iconColor: Colors.blueGrey,
                    iconBg: const Color(0xFFECEFF1),
                    title: AppLocalizations.of(context)!.themeTitle,
                    trailing: PopupMenuButton<ThemeModeOption>(
                      onSelected: (ThemeModeOption selected) {
                        ref.read(themeModeProvider.notifier).setThemeMode(selected);
                      },
                      itemBuilder: (BuildContext context) => ThemeModeOption.values.map((option) => _buildMenuItem(context, option, theme, themeModeOption)).toList(),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            themeModeOption.localized(context),
                            style: theme.textTheme.labelMedium,
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.chevron_right, color: theme.dividerTheme.color),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // 4. Sección Información
              _SectionHeader(title: AppLocalizations.of(context)!.infoHeader),
              _SettingsGroup(
                children: [
                  _SettingsTile(
                    title: AppLocalizations.of(context)!.privacyPolicy,
                    showArrow: true,
                  ),
                  _CustomDivider(),
                  _SettingsTile(
                    title: AppLocalizations.of(context)!.aboutApp,
                    showArrow: true,
                  ),
                ],
              ),
              const SizedBox(height: 30),



              // 6. Footer Versión
              Center(
                child: Column(
                  children: [
                    Text(AppLocalizations.of(context)!.versionLabel, style: theme.textTheme.labelSmall),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud, size: 12, color: theme.iconTheme.color?.withValues(alpha: 0.6)),
                        const SizedBox(width: 4),
                        Text(AppLocalizations.of(context)!.dataProviderCredit, style: theme.textTheme.labelSmall),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(AppLocalizations.of(context)!.errorLoadingTheme(error))),
      ),
    );
  }

  PopupMenuItem<ThemeModeOption> _buildMenuItem(BuildContext context, ThemeModeOption option, ThemeData theme, ThemeModeOption current) {
    final bool isSelected = current == option;

    // Simple styling: selected has a background
    final selectedBg = isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent;
    final selectedTextColor = isSelected ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color;

    return PopupMenuItem<ThemeModeOption>(
      value: option,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selectedBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          option.localized(context),
          style: TextStyle(color: selectedTextColor),
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
