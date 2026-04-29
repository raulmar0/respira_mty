import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:respira_mty/l10n/app_localizations.dart';
import 'package:respira_mty/models/alert_event.dart';
import 'package:respira_mty/utils/air_quality_scale.dart';

/// Card rendering one [AlertEvent] in the notifications list.
///
/// Icon background and accent color come from the event's category via
/// [AirQualityScale.getBackgroundColorForCategory] / [getColorForCategory],
/// so `bad` is orange, `veryBad` red, `extremelyBad` purple, etc.
///
/// Shows an unread dot when [AlertEvent.read] is false, and formats
/// [AlertEvent.firedAt] as a short relative time using device locale.
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    required this.event,
    this.onTap,
    super.key,
  });

  final AlertEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final iconBg =
        AirQualityScale.getBackgroundColorForCategory(event.category);
    final iconColor = AirQualityScale.getColorForCategory(event.category);
    final time = _formatRelative(event.firedAt.toLocal(), DateTime.now(), loc);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_iconFor(event), color: iconColor),
                ),
                if (!event.read)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.cardTheme.color ?? Colors.white,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event.titleSnapshot,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(time, style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    event.bodySnapshot,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(height: 1.4, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _iconFor(AlertEvent event) {
    switch (event.reason) {
      case AlertReason.improvementBackToGood:
        return Icons.spa_outlined;
      case AlertReason.crossingThreshold:
      case AlertReason.worseningCategory:
        return Icons.warning_amber_rounded;
    }
  }

  static String _formatRelative(
    DateTime time,
    DateTime now,
    AppLocalizations loc,
  ) {
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours} h';
    if (diff.inDays < 7) return '${diff.inDays} d';
    return DateFormat.MMMd(loc.localeName).format(time);
  }
}
