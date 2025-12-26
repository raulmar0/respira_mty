import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:respira_mty/l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import 'settings_screen.dart';


class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> with AutomaticKeepAliveClientMixin<NotificationsScreen> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isCriticalEnabled = ref.watch(criticalAlertsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Cabecera
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.notificationsTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                  TextButton(
                    onPressed: () {},
                    // Mantenemos el color primario para la acción
                    child: Text(AppLocalizations.of(context)!.markAllRead, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                  )
                ],
              ),
              const SizedBox(height: 25),

              // 2. Filtros (Chips) - AHORA CON LOS NUEVOS COLORES
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                // Añadimos un poco de padding para que la sombra no se corte
                padding: const EdgeInsets.only(bottom: 10, left: 2, right: 2),
                child: Row(
                  children: const [
                    _FilterChip(label: "Todas", isSelected: true),
                    _FilterChip(label: "Alertas", isSelected: false),
                    _FilterChip(label: "Sistema", isSelected: false),
                    _FilterChip(label: "Consejos", isSelected: false),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Sección HOY
              if (!isCriticalEnabled)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Alertas críticas desactivadas. Actívalas en Ajustes para recibir notificaciones importantes.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
                        child: Text(AppLocalizations.of(context)!.goToSettings),
                      )
                    ],
                  ),
                ),
              const Text("HOY", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 10),

              const _NotificationCard(
                icon: Icons.warning_amber_rounded,
                iconColor: Colors.redAccent,
                iconBg: Color(0xFFFDE8E8),
                title: "Calidad del aire: Mala",
                time: "10 min",
                body: "El nivel de PM2.5 ha subido drásticamente en la zona de San Pedro. Se recomienda usar...",
                showDot: true,
              ),
              const _NotificationCard(
                icon: Icons.water_drop_outlined,
                iconColor: Colors.blueAccent,
                iconBg: Color(0xFFE3F2FD),
                title: "Pronóstico de lluvia",
                time: "2 h",
                body: "Se espera lluvia ligera en las próximas horas que podría ayudar a limpiar el aire.",
                showDot: true,
              ),

              const SizedBox(height: 20),

              // 4. Sección AYER
              const Text("AYER", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 10),

              const _NotificationCard(
                icon: Icons.location_on_outlined,
                iconColor: Colors.grey,
                iconBg: Color(0xFFEEEEEE),
                title: "Nueva estación añadida",
                time: "1 d",
                body: "Ahora monitoreamos la calidad del aire en la zona de Santa Catarina.",
                showDot: false,
              ),
              const _NotificationCard(
                icon: Icons.spa_outlined,
                iconColor: Colors.green,
                iconBg: Color(0xFFE8F5E9),
                title: "Recomendación de salud",
                time: "2 d",
                body: "Los niveles de polen son altos. Evita actividades al aire libre si eres alérgico.",
                showDot: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget auxiliar para las tarjetas de notificación
class _NotificationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String time;
  final String body;
  final bool showDot;

  const _NotificationCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.time,
    required this.body,
    required this.showDot,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono con punto verde opcional
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor),
              ),
              if (showDot)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.cardTheme.color ?? Colors.white, width: 1.5),
                    ),
                  ),
                )
            ],
          ),
          const SizedBox(width: 15),
          // Textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(time, style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color)),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Widget auxiliar para los filtros (chips)
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color selectedBgColor = theme.colorScheme.primary;
    final Color unselectedBgColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final Color unselectedTextColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? selectedBgColor : unselectedBgColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: selectedBgColor.withValues(alpha: 0.24),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? (theme.colorScheme.onPrimary) : unselectedTextColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}
