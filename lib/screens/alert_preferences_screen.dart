import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:respira_mty/l10n/app_localizations.dart';
import 'package:respira_mty/models/alert_event.dart';
import 'package:respira_mty/models/alert_preferences.dart';
import 'package:respira_mty/providers/alert_preferences_provider.dart';
import 'package:respira_mty/services/alerts/notification_service.dart';
import 'package:respira_mty/utils/air_quality_scale.dart';
import 'package:respira_mty/widgets/permission_rationale_sheet.dart';

/// Sub-screen for managing alert preferences. Pushed from the "Alertas
/// Críticas" tile in [SettingsScreen].
class AlertPreferencesScreen extends ConsumerWidget {
  const AlertPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final asyncPrefs = ref.watch(alertPreferencesProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.iconTheme.color),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(loc.alertPrefsTitle, style: theme.appBarTheme.titleTextStyle),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: asyncPrefs.when(
        data: (prefs) => _PreferencesBody(prefs: prefs),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Error: $e'),
          ),
        ),
      ),
    );
  }
}

class _PreferencesBody extends ConsumerStatefulWidget {
  const _PreferencesBody({required this.prefs});
  final AlertPreferences prefs;

  @override
  ConsumerState<_PreferencesBody> createState() => _PreferencesBodyState();
}

class _PreferencesBodyState extends ConsumerState<_PreferencesBody> {
  Future<bool> _ensurePermission(BuildContext context) async {
    final granted = await NotificationService.instance.isPermissionGranted();
    if (granted) return true;
    if (!context.mounted) return false;
    return PermissionRationaleSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final prefs = widget.prefs;
    final notifier = ref.read(alertPreferencesProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Master switch
          _SectionCard(
            child: SwitchListTile(
              value: prefs.enabled,
              onChanged: (v) async {
                if (v) {
                  final granted = await _ensurePermission(context);
                  await notifier.setEnabled(granted);
                  if (!granted && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.permissionDeniedBanner)),
                    );
                  }
                } else {
                  await notifier.setEnabled(false);
                }
              },
              title: Text(loc.alertPrefsEnableTitle,
                  style: theme.textTheme.labelLarge),
              subtitle: Text(loc.alertPrefsEnableSubtitle,
                  style: theme.textTheme.bodySmall),
            ),
          ),
          const SizedBox(height: 20),

          // Threshold
          _SectionHeader(title: loc.alertPrefsThresholdHeader),
          _SectionCard(
            child: Column(
              children: [
                _ThresholdRadio(
                  category: AirQualityCategory.acceptable,
                  selected: prefs.threshold,
                  label: loc.alertPrefsThresholdAcceptable,
                  onChanged: notifier.setThreshold,
                ),
                _ThresholdRadio(
                  category: AirQualityCategory.bad,
                  selected: prefs.threshold,
                  label: loc.alertPrefsThresholdBad,
                  onChanged: notifier.setThreshold,
                ),
                _ThresholdRadio(
                  category: AirQualityCategory.veryBad,
                  selected: prefs.threshold,
                  label: loc.alertPrefsThresholdVeryBad,
                  onChanged: notifier.setThreshold,
                ),
                _ThresholdRadio(
                  category: AirQualityCategory.extremelyBad,
                  selected: prefs.threshold,
                  label: loc.alertPrefsThresholdExtreme,
                  onChanged: notifier.setThreshold,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Scope
          _SectionHeader(title: loc.alertPrefsScopeHeader),
          _SectionCard(
            child: Column(
              children: [
                RadioListTile<AlertScope>(
                  title: Text(loc.alertPrefsScopeAll),
                  value: AlertScope.all,
                  // ignore: deprecated_member_use
                  groupValue: prefs.scope,
                  // ignore: deprecated_member_use
                  onChanged: (v) => v != null ? notifier.setScope(v) : null,
                ),
                RadioListTile<AlertScope>(
                  title: Text(loc.alertPrefsScopeFavorites),
                  value: AlertScope.favorites,
                  // ignore: deprecated_member_use
                  groupValue: prefs.scope,
                  // ignore: deprecated_member_use
                  onChanged: (v) => v != null ? notifier.setScope(v) : null,
                ),
                RadioListTile<AlertScope>(
                  title: Text(loc.alertPrefsScopeNearest),
                  value: AlertScope.nearest,
                  // ignore: deprecated_member_use
                  groupValue: prefs.scope,
                  // ignore: deprecated_member_use
                  onChanged: (v) => v != null ? notifier.setScope(v) : null,
                ),
                if (prefs.scope == AlertScope.nearest)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.alertPrefsNearestRadiusLabel(
                              prefs.nearestRadiusKm),
                          style: theme.textTheme.bodySmall,
                        ),
                        Slider(
                          min: 1,
                          max: 10,
                          divisions: 9,
                          value: prefs.nearestRadiusKm.toDouble(),
                          label: '${prefs.nearestRadiusKm} km',
                          onChanged: (v) =>
                              notifier.setNearestRadiusKm(v.round()),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quiet hours
          _SectionHeader(title: loc.alertPrefsQuietHoursHeader),
          _SectionCard(
            child: Column(
              children: [
                SwitchListTile(
                  value: prefs.quietHours.enabled,
                  onChanged: (v) => notifier.setQuietHours(
                    prefs.quietHours.copyWith(enabled: v),
                  ),
                  title: Text(loc.alertPrefsQuietHoursHeader,
                      style: theme.textTheme.labelLarge),
                ),
                if (prefs.quietHours.enabled) ...[
                  ListTile(
                    title: Text(loc.alertPrefsQuietStart),
                    trailing:
                        Text(_formatMinute(prefs.quietHours.startMinute)),
                    onTap: () => _pickTime(
                      context,
                      prefs.quietHours.startMinute,
                      (m) => notifier.setQuietHours(
                          prefs.quietHours.copyWith(startMinute: m)),
                    ),
                  ),
                  ListTile(
                    title: Text(loc.alertPrefsQuietEnd),
                    trailing:
                        Text(_formatMinute(prefs.quietHours.endMinute)),
                    onTap: () => _pickTime(
                      context,
                      prefs.quietHours.endMinute,
                      (m) => notifier.setQuietHours(
                          prefs.quietHours.copyWith(endMinute: m)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Pollutant mute
          _SectionHeader(title: loc.alertPrefsPollutantsHeader),
          _SectionCard(
            child: Column(
              children: [
                for (final p in _pollutantNames)
                  SwitchListTile(
                    title: Text(p),
                    value: !prefs.mutedPollutants.contains(p),
                    onChanged: (_) => notifier.togglePollutantMute(p),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Improvement
          _SectionCard(
            child: SwitchListTile(
              value: prefs.notifyOnImprovement,
              onChanged: notifier.setNotifyOnImprovement,
              title: Text(loc.alertPrefsImprovementTitle,
                  style: theme.textTheme.labelLarge),
              subtitle: Text(loc.alertPrefsImprovementSubtitle,
                  style: theme.textTheme.bodySmall),
            ),
          ),
          const SizedBox(height: 20),

          // Cooldown
          _SectionHeader(title: loc.alertPrefsCooldownHeader),
          _SectionCard(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.alertPrefsCooldownLabel(prefs.cooldownHours),
                    style: theme.textTheme.bodySmall,
                  ),
                  Slider(
                    min: 1,
                    max: 24,
                    divisions: 23,
                    value: prefs.cooldownHours.toDouble(),
                    label: '${prefs.cooldownHours} h',
                    onChanged: (v) => notifier.setCooldownHours(v.round()),
                  ),
                ],
              ),
            ),
          ),

          if (kDebugMode) ...[
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () async {
                final fixture = AlertEvent(
                  id: AlertEvent.generateId(),
                  stationId: 'centro',
                  stationName: 'Centro (debug)',
                  category: AirQualityCategory.veryBad,
                  dominantPollutant: 'PM2.5',
                  dominantValue: 95.0,
                  unit: 'µg/m³',
                  firedAt: DateTime.now().toUtc(),
                  localeAtFire: loc.localeName,
                  titleSnapshot: loc.alertEventTitleCrossing(loc.airQualityVeryBad),
                  bodySnapshot: loc.alertEventBodyCrossing(
                      'Centro (debug)', 'PM2.5', '95', 'µg/m³'),
                  read: false,
                  reason: AlertReason.crossingThreshold,
                );
                await NotificationService.instance.show(fixture);
              },
              icon: const Icon(Icons.science_outlined),
              label: Text(loc.alertPrefsTestButton),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    int currentMinute,
    void Function(int) onPicked,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: currentMinute ~/ 60,
        minute: currentMinute % 60,
      ),
    );
    if (picked != null) {
      onPicked(picked.hour * 60 + picked.minute);
    }
  }

  static String _formatMinute(int m) {
    final h = m ~/ 60;
    final min = m % 60;
    return '${h.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}';
  }
}

const List<String> _pollutantNames = [
  'PM2.5',
  'PM10',
  'O3',
  'NO2',
  'SO2',
  'CO',
];

class _ThresholdRadio extends StatelessWidget {
  const _ThresholdRadio({
    required this.category,
    required this.selected,
    required this.label,
    required this.onChanged,
  });

  final AirQualityCategory category;
  final AirQualityCategory selected;
  final String label;
  final void Function(AirQualityCategory) onChanged;

  @override
  Widget build(BuildContext context) {
    final color = AirQualityScale.getColorForCategory(category);
    return RadioListTile<AirQualityCategory>(
      value: category,
      // ignore: deprecated_member_use
      groupValue: selected,
      // ignore: deprecated_member_use
      onChanged: (v) => v != null ? onChanged(v) : null,
      title: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}
