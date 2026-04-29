import 'package:flutter/widgets.dart';
import 'package:respira_mty/l10n/app_localizations.dart';
import 'package:respira_mty/models/alert_event.dart';
import 'package:respira_mty/services/air_quality_service.dart';
import 'package:respira_mty/services/alerts/alert_baseline_store.dart';
import 'package:respira_mty/services/alerts/alert_copy.dart';
import 'package:respira_mty/services/alerts/alert_evaluator.dart';
import 'package:respira_mty/services/alerts/alert_history_repository.dart';
import 'package:respira_mty/services/alerts/alert_preferences_repository.dart';
import 'package:respira_mty/services/alerts/notification_service.dart';
import 'package:respira_mty/utils/air_quality_scale.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

/// Workmanager task identifier registered in `main.dart`. Must match the
/// `uniqueName` passed to `Workmanager().registerPeriodicTask(...)`.
const String alertPollTaskName = 'pollAirQualityAndAlert';

/// Top-level entry point for the Workmanager background isolate. Required to
/// be top-level + `vm:entry-point` so tree-shaking does not strip it.
///
/// On each invocation:
/// 1. Initializes Flutter bindings + the notification plugin.
/// 2. Loads alert preferences. If disabled, returns early (cheap no-op).
/// 3. Fetches latest stations from SIMA and seeds the baseline silently on
///    first run (no notifications fired the very first time alerts are
///    enabled, to avoid bombarding the user).
/// 4. Runs the [AlertEvaluator] against current data + recent history +
///    baseline.
/// 5. For each emitted [AlertRule]: persists an [AlertEvent], shows a
///    notification, and updates the baseline.
///
/// All errors are swallowed (logged via [debugPrint]) — failure during a
/// background poll should never crash the OS-level task scheduler.
@pragma('vm:entry-point')
void alertBackgroundCallback() {
  Workmanager().executeTask((task, inputData) async {
    if (task != alertPollTaskName) return Future.value(true);

    try {
      WidgetsFlutterBinding.ensureInitialized();
      await NotificationService.instance.initialize();

      final prefsRepo = AlertPreferencesRepository();
      final prefs = await prefsRepo.load();
      if (!prefs.enabled) return Future.value(true);

      final historyRepo = AlertHistoryRepository();
      final history = await historyRepo.loadAll();
      final baselineStore = AlertBaselineStore();
      final baseline = await baselineStore.load();

      final stations = await AirQualityService().fetchStations();
      if (stations.isEmpty) return Future.value(true);

      // First-run baseline guard: seed silently from current data instead of
      // firing alerts for stations that were already in a bad state when the
      // user first enabled the feature.
      if (baseline.isEmpty) {
        final snapshot = <String, AirQualityCategory>{
          for (final s in stations) s.id: s.dominantPollutant.category,
        };
        await baselineStore.seed(snapshot);
        return Future.value(true);
      }

      // Background isolates can't reuse the UI Riverpod container, so we
      // resolve favorites and locale directly from shared_preferences. The
      // FavoritesNotifier in the UI is in-memory only at the moment, so the
      // background path uses an empty set: scope=favorites won't fire from
      // the background, but scope=all and scope=nearest still work.
      final spPrefs = await SharedPreferences.getInstance();
      final favorites = <String>{};

      final localeCode = _languageToLocale(spPrefs.getString('app_language'));
      final loc = await AppLocalizations.delegate.load(Locale(localeCode));

      final rules = AlertEvaluator().evaluate(
        stations: stations,
        prefs: prefs,
        lastSeenByStation: baseline,
        recentHistory: history,
        favorites: favorites,
        now: DateTime.now(),
        userLocation: null, // background can't use geolocator reliably
      );

      for (final rule in rules) {
        final firedAt = DateTime.now().toUtc();
        final event = AlertEvent(
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

        await historyRepo.append(event);
        await NotificationService.instance.show(event);
        await baselineStore.upsert(rule.stationId, rule.category, firedAt);
      }

      return Future.value(true);
    } catch (e, st) {
      debugPrint('alertBackgroundCallback error: $e\n$st');
      return Future.value(true);
    }
  });
}

/// Maps the persisted [AppLanguage].name strings (`'spanish'`, `'english'`,
/// etc.) to BCP-47 locale codes used by [AppLocalizations.delegate]. Falls
/// back to Spanish (the app's primary locale) on null/unknown input.
String _languageToLocale(String? name) {
  switch (name) {
    case 'english':
      return 'en';
    case 'french':
      return 'fr';
    case 'korean':
      return 'ko';
    case 'spanish':
    default:
      return 'es';
  }
}
