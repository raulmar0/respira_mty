import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:respira_mty/l10n/app_localizations.dart';
import 'package:respira_mty/models/alert_event.dart';
import 'package:respira_mty/providers/alert_history_provider.dart';
import 'package:respira_mty/providers/alert_preferences_provider.dart';
import 'package:respira_mty/widgets/notification_card.dart';
import 'alert_preferences_screen.dart';
import 'settings_screen.dart';

enum _NotifFilter { all, alerts }

class _NotifFilterNotifier extends Notifier<_NotifFilter> {
  @override
  _NotifFilter build() => _NotifFilter.all;
  void set(_NotifFilter v) => state = v;
}

final _notifFilterProvider =
    NotifierProvider<_NotifFilterNotifier, _NotifFilter>(_NotifFilterNotifier.new);

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with AutomaticKeepAliveClientMixin<NotificationsScreen> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final isCriticalEnabled =
        ref.watch(alertPreferencesProvider).value?.enabled ?? false;
    final filter = ref.watch(_notifFilterProvider);
    final groupedAsync = ref.watch(groupedAlertHistoryProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(alertHistoryProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.notificationsTitle,
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold, fontSize: 28),
                    ),
                    TextButton(
                      onPressed: () => ref
                          .read(alertHistoryProvider.notifier)
                          .markAllRead(),
                      child: Text(
                        loc.markAllRead,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.only(bottom: 10, left: 2, right: 2),
                  child: Row(
                    children: [
                      _FilterChip(
                        label: loc.notifFilterAll,
                        selected: filter == _NotifFilter.all,
                        onTap: () => ref
                            .read(_notifFilterProvider.notifier)
                            .set(_NotifFilter.all),
                      ),
                      _FilterChip(
                        label: loc.notifFilterAlerts,
                        selected: filter == _NotifFilter.alerts,
                        onTap: () => ref
                            .read(_notifFilterProvider.notifier)
                            .set(_NotifFilter.alerts),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Disabled-alerts banner
                if (!isCriticalEnabled)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            loc.criticalAlertsSubtitle,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AlertPreferencesScreen(),
                            ),
                          ),
                          child: Text(loc.goToSettings),
                        ),
                      ],
                    ),
                  ),

                // History
                groupedAsync.when(
                  data: (groups) => _HistoryList(
                    today: groups.today,
                    yesterday: groups.yesterday,
                    earlier: groups.earlier,
                    onTap: (event) => ref
                        .read(alertHistoryProvider.notifier)
                        .markRead(event.id),
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        loc.errorLoadingAirQuality,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({
    required this.today,
    required this.yesterday,
    required this.earlier,
    required this.onTap,
  });

  final List<AlertEvent> today;
  final List<AlertEvent> yesterday;
  final List<AlertEvent> earlier;
  final void Function(AlertEvent) onTap;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (today.isEmpty && yesterday.isEmpty && earlier.isEmpty) {
      return _EmptyState(title: loc.notifEmptyTitle, body: loc.notifEmptyBody);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (today.isNotEmpty) ...[
          _SectionLabel(label: loc.today),
          for (final e in today) NotificationCard(event: e, onTap: () => onTap(e)),
          const SizedBox(height: 20),
        ],
        if (yesterday.isNotEmpty) ...[
          _SectionLabel(label: loc.yesterday),
          for (final e in yesterday)
            NotificationCard(event: e, onTap: () => onTap(e)),
          const SizedBox(height: 20),
        ],
        if (earlier.isNotEmpty) ...[
          _SectionLabel(label: loc.notifSectionEarlier),
          for (final e in earlier)
            NotificationCard(event: e, onTap: () => onTap(e)),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 56,
            color: theme.iconTheme.color?.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedBgColor = theme.colorScheme.primary;
    final unselectedBgColor =
        theme.cardTheme.color ?? theme.colorScheme.surface;
    final unselectedTextColor =
        theme.textTheme.bodyMedium?.color ?? Colors.grey;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? selectedBgColor : unselectedBgColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: selectedBgColor.withValues(alpha: 0.24),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? theme.colorScheme.onPrimary : unselectedTextColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// Re-export so old imports of SettingsScreen-related symbols stay valid.
// ignore: unused_element
typedef _SettingsScreen = SettingsScreen;
