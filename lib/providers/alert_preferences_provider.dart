import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:respira_mty/models/alert_preferences.dart';
import 'package:respira_mty/services/alerts/alert_preferences_repository.dart';
import 'package:respira_mty/utils/air_quality_scale.dart';

/// AsyncNotifier wrapping [AlertPreferencesRepository]. The state is the
/// current [AlertPreferences]; mutations write through to shared_preferences
/// and update state on success.
class AlertPreferencesNotifier extends AsyncNotifier<AlertPreferences> {
  AlertPreferencesRepository _repo = AlertPreferencesRepository();

  @override
  Future<AlertPreferences> build() => _repo.load();

  Future<void> _update(AlertPreferences next) async {
    state = AsyncValue.data(next);
    await _repo.save(next);
  }

  Future<void> setEnabled(bool enabled) async {
    final current = state.value ?? AlertPreferences.defaults();
    await _update(current.copyWith(enabled: enabled));
  }

  Future<void> setThreshold(AirQualityCategory threshold) async {
    final current = state.value ?? AlertPreferences.defaults();
    await _update(current.copyWith(threshold: threshold));
  }

  Future<void> setScope(AlertScope scope) async {
    final current = state.value ?? AlertPreferences.defaults();
    await _update(current.copyWith(scope: scope));
  }

  Future<void> setNearestRadiusKm(int km) async {
    final current = state.value ?? AlertPreferences.defaults();
    await _update(current.copyWith(nearestRadiusKm: km));
  }

  Future<void> setQuietHours(QuietHours quietHours) async {
    final current = state.value ?? AlertPreferences.defaults();
    await _update(current.copyWith(quietHours: quietHours));
  }

  Future<void> togglePollutantMute(String pollutant) async {
    final current = state.value ?? AlertPreferences.defaults();
    final muted = <String>{...current.mutedPollutants};
    if (!muted.remove(pollutant)) muted.add(pollutant);
    await _update(current.copyWith(mutedPollutants: muted));
  }

  Future<void> setCooldownHours(int hours) async {
    final current = state.value ?? AlertPreferences.defaults();
    await _update(current.copyWith(cooldownHours: hours));
  }

  Future<void> setNotifyOnImprovement(bool value) async {
    final current = state.value ?? AlertPreferences.defaults();
    await _update(current.copyWith(notifyOnImprovement: value));
  }

  /// Inject a different repository instance for testing.
  // ignore: avoid_setters_without_getters
  set debugRepository(AlertPreferencesRepository repo) => _repo = repo;
}

final alertPreferencesProvider =
    AsyncNotifierProvider<AlertPreferencesNotifier, AlertPreferences>(
  AlertPreferencesNotifier.new,
);
