import 'package:flutter/material.dart';
import 'package:respira_mty/l10n/app_localizations.dart';
import 'package:respira_mty/services/alerts/notification_service.dart';

/// Bottom sheet shown before calling the system notification-permission
/// prompt. Explains *why* alerts are useful, then either requests permission
/// (first invocation) or deep-links to system settings (subsequent
/// invocations after a denial).
///
/// Returns `true` from `Navigator.pop` if permission was granted, `false`
/// otherwise.
class PermissionRationaleSheet extends StatelessWidget {
  const PermissionRationaleSheet({
    this.previouslyDenied = false,
    super.key,
  });

  /// When true, the primary action becomes "Open Settings" instead of
  /// "Enable" — tapping it opens the system app settings page so the user
  /// can flip the permission manually.
  final bool previouslyDenied;

  static Future<bool> show(
    BuildContext context, {
    bool previouslyDenied = false,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PermissionRationaleSheet(
        previouslyDenied: previouslyDenied,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_active_outlined,
                  color: theme.colorScheme.primary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                loc.permissionRationaleTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                loc.permissionRationaleBody,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                loc.alertPrefsIosLatencyNotice,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color
                      ?.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  if (previouslyDenied) {
                    await NotificationService.instance.openSystemSettings();
                    if (context.mounted) Navigator.of(context).pop(false);
                    return;
                  }
                  final granted =
                      await NotificationService.instance.requestPermission();
                  if (context.mounted) Navigator.of(context).pop(granted);
                },
                child: Text(
                  previouslyDenied
                      ? loc.permissionDeniedOpenSettings
                      : loc.permissionRationaleEnable,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(loc.permissionRationaleLater),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
