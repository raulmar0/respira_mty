import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:respira_mty/l10n/app_localizations.dart';
import '../models/app_notification.dart';
import '../providers/notification_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/air_quality_scale.dart';
import 'settings_screen.dart';


class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> with AutomaticKeepAliveClientMixin<NotificationsScreen> {
  @override
  bool get wantKeepAlive => true;

  String _selectedFilter = 'Todas';

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isCriticalEnabled = ref.watch(criticalAlertsProvider);
    final historyAsync = ref.watch(notificationHistoryProvider);

    // Activate foreground alert evaluation
    ref.watch(foregroundAlertProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.notificationsTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(notificationHistoryProvider.notifier).markAllAsRead();
                    },
                    child: Text(AppLocalizations.of(context)!.markAllRead, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                  )
                ],
              ),
              const SizedBox(height: 25),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 10, left: 2, right: 2),
                child: Row(
                  children: [
                    _FilterChip(
                      label: "Todas",
                      isSelected: _selectedFilter == 'Todas',
                      onTap: () => setState(() => _selectedFilter = 'Todas'),
                    ),
                    _FilterChip(
                      label: "Alertas",
                      isSelected: _selectedFilter == 'Alertas',
                      onTap: () => setState(() => _selectedFilter = 'Alertas'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Critical alerts warning banner
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

              // Notification list
              historyAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return _buildEmptyState(theme);
                  }

                  // Group by date
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final yesterday = today.subtract(const Duration(days: 1));

                  final todayNotifs = <AppNotification>[];
                  final yesterdayNotifs = <AppNotification>[];
                  final olderNotifs = <AppNotification>[];

                  for (final n in notifications) {
                    final date = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
                    if (date == today) {
                      todayNotifs.add(n);
                    } else if (date == yesterday) {
                      yesterdayNotifs.add(n);
                    } else {
                      olderNotifs.add(n);
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (todayNotifs.isNotEmpty) ...[
                        const Text("HOY", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 10),
                        ...todayNotifs.map((n) => _buildNotificationCard(n, theme)),
                        const SizedBox(height: 20),
                      ],
                      if (yesterdayNotifs.isNotEmpty) ...[
                        const Text("AYER", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 10),
                        ...yesterdayNotifs.map((n) => _buildNotificationCard(n, theme)),
                        const SizedBox(height: 20),
                      ],
                      if (olderNotifs.isNotEmpty) ...[
                        const Text("ANTERIORES", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 10),
                        ...olderNotifs.map((n) => _buildNotificationCard(n, theme)),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.notifications_off_outlined, size: 64, color: theme.disabledColor),
            const SizedBox(height: 16),
            Text(
              'Sin notificaciones',
              style: theme.textTheme.titleMedium?.copyWith(color: theme.disabledColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Las alertas de calidad del aire aparecerán aquí.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.disabledColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification, ThemeData theme) {
    final iconData = _iconForCategory(notification.category);
    final iconColor = AirQualityScale.getColorForCategory(notification.category);
    final iconBg = AirQualityScale.getBackgroundColorForCategory(notification.category);
    final statusText = AirQualityScale.getStatusForCategory(notification.category);
    final timeAgo = _formatTimeAgo(notification.createdAt);

    final valueStr = notification.pollutantName == 'CO'
        ? notification.pollutantValue.toStringAsFixed(1)
        : notification.pollutantValue.toStringAsFixed(0);

    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          ref.read(notificationHistoryProvider.notifier).markAsRead(notification.id);
        }
      },
      child: _NotificationCard(
        icon: iconData,
        iconColor: iconColor,
        iconBg: iconBg,
        title: 'Calidad del aire: $statusText',
        time: timeAgo,
        body: '${notification.pollutantName} en ${notification.stationName}: $valueStr ${notification.pollutantUnit}',
        showDot: !notification.isRead,
      ),
    );
  }

  IconData _iconForCategory(AirQualityCategory category) {
    switch (category) {
      case AirQualityCategory.extremelyBad:
        return Icons.dangerous_outlined;
      case AirQualityCategory.veryBad:
        return Icons.warning_rounded;
      case AirQualityCategory.bad:
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline;
    }
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours} h';
    if (diff.inDays < 7) return '${diff.inDays} d';
    return '${date.day}/${date.month}';
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
          // Icon with optional unread dot
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
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
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
  final VoidCallback? onTap;

  const _FilterChip({required this.label, required this.isSelected, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color selectedBgColor = theme.colorScheme.primary;
    final Color unselectedBgColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final Color unselectedTextColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}
