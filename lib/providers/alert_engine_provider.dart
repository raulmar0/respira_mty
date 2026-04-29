import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:respira_mty/l10n/app_localizations.dart';
import 'package:respira_mty/models/alert_event.dart';
import 'package:respira_mty/models/alert_preferences.dart';
import 'package:respira_mty/models/alert_rule.dart';
import 'package:respira_mty/models/station.dart';
import 'package:respira_mty/providers/alert_history_provider.dart';
import 'package:respira_mty/providers/alert_preferences_provider.dart';
import 'package:respira_mty/providers/location_provider.dart';
import 'package:respira_mty/providers/settings_provider.dart';
import 'package:respira_mty/providers/station_provider.dart';
import 'package:respira_mty/services/alerts/alert_baseline_store.dart';
import 'package:respira_mty/services/alerts/alert_copy.dart';
import 'package:respira_mty/services/alerts/alert_evaluator.dart';
import 'package:respira_mty/services/alerts/alert_history_repository.dart';
import 'package:respira_mty/services/alerts/notification_service.dart';
import 'package:respira_mty/utils/air_quality_scale.dart';

/// Foreground trigger for the alert engine. Listens to [airQualityProvider]
/// and to [alertPreferencesProvider]; whenever fresh stations land it runs
/// the [AlertEvaluator], persists fired [AlertEvent]s to the history repo,
/// emits OS notifications via [NotificationService], and updates the
/// per-station baseline.
///
/// First-run safety: on the very first foreground evaluation (empty baseline)
/// it seeds silently from current categories without firing — same behavior
/// as the background callback, so the user isn't bombarded when they first
/// turn alerts on with already-bad stations.
class AlertEngine {
  AlertEngine(this._ref) {
    // Re-evaluate when fresh data arrives.
    _ref.listen<AsyncValue<List<Station>>>(airQualityProvider,
        (prev, next) => _onStationsUpdate(next));
    // Re-evaluate when the user just enabled alerts (catches the case where
    // data was already cached but engine had no work to do).
    _ref.listen<AsyncValue<AlertPreferences>>(
      alertPreferencesProvider,
      (prev, next) {
        final wasEnabled = prev?.value?.enabled ?? false;
        final isEnabled = next.value?.enabled ?? false;
        if (!wasEnabled && isEnabled) {
          final stationsAsync = _ref.read(airQualityProvider);
          _onStationsUpdate(stationsAsync);
        }
      },
    );
  }

  final Ref _ref;
  final AlertHistoryRepository _historyRepo = AlertHistoryRepository();
  final AlertBaselineStore _baselineStore = AlertBaselineStore();
  final AlertEvaluator _evaluator = AlertEvaluator();

  bool _running = false;

  Future<void> _onStationsUpdate(
      AsyncValue<List<Station>> stationsAsync) async {
    final stations = stationsAsync.value;
    if (stations == null || stations.isEmpty) return;
    if (_running) return; // avoid concurrent runs
    _running = true;
    try {
      final prefs = _ref.read(alertPreferencesProvider).value;
      if (prefs == null || !prefs.enabled) return;

      final baseline = await _baselineStore.load();
      // First-run: seed silently and exit.
      if (baseline.isEmpty) {
        final snapshot = <String, AirQualityCategory>{
          for (final s in stations) s.id: s.dominantPollutant.category,
        };
        await _baselineStore.seed(snapshot);
        return;
      }

      final favorites = _ref.read(favoriteStationsProvider);
      final history = await _historyRepo.loadAll();
      final userLocation =
          _ref.read(currentLocationProvider).maybeWhen(
                data: (latlng) => latlng,
                orElse: () => null,
              );

      final rules = _evaluator.evaluate(
        stations: stations,
        prefs: prefs,
        lastSeenByStation: baseline,
        recentHistory: history,
        favorites: favorites,
        now: DateTime.now(),
        userLocation: userLocation,
      );

      if (rules.isEmpty) return;

      final language = _ref.read(languageProvider);
      final localeCode = language.locale.languageCode;
      final loc = await AppLocalizations.delegate.load(Locale(localeCode));

      for (final rule in rules) {
        final firedAt = DateTime.now().toUtc();
        final event = _ruleToEvent(rule, loc, localeCode, firedAt);

        await _historyRepo.append(event);
        await NotificationService.instance.show(event);
        await _baselineStore.upsert(rule.stationId, rule.category, firedAt);
      }

      // Refresh history provider so the UI reflects new events immediately.
      await _ref.read(alertHistoryProvider.notifier).refresh();
    } finally {
      _running = false;
    }
  }

  AlertEvent _ruleToEvent(
    AlertRule rule,
    AppLocalizations loc,
    String localeCode,
    DateTime firedAt,
  ) {
    return AlertEvent(
      id: AlertEvent.generateId(),
      stationId: rule.stationId,
      stationName: rule.stationName,
      category: rule.category,
      dominantPollutant: rule.dominantPollutant,
      dominantValue: rule.value,
      unit: rule.unit,
      firedAt: firedAt,
      localeAtFire: localeCode,
      titleSnapshot: AlertCopy.title(loc, rule),
      bodySnapshot: AlertCopy.body(loc, rule),
      read: false,
      reason: rule.reason,
    );
  }
}

/// The foreground engine. `MainShell` calls `ref.read(alertEngineProvider)`
/// in `initState` to bootstrap the listener; the provider keeps the engine
/// alive for the duration of the ProviderContainer.
final alertEngineProvider = Provider<AlertEngine>((ref) {
  final engine = AlertEngine(ref);
  return engine;
});
