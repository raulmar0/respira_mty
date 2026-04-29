import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:respira_mty/models/alert_event.dart';
import 'package:respira_mty/services/alerts/alert_history_repository.dart';

/// Grouping of alert events by recency, used by the notifications screen.
typedef AlertHistoryGroups = ({
  List<AlertEvent> today,
  List<AlertEvent> yesterday,
  List<AlertEvent> earlier,
});

/// AsyncNotifier wrapping [AlertHistoryRepository]. State is the full event
/// list (newest first), capped at 100 by the repo.
class AlertHistoryNotifier extends AsyncNotifier<List<AlertEvent>> {
  AlertHistoryRepository _repo = AlertHistoryRepository();

  @override
  Future<List<AlertEvent>> build() => _repo.loadAll();

  /// Re-read from disk. Useful after the background isolate writes.
  Future<void> refresh() async {
    final events = await _repo.loadAll();
    state = AsyncValue.data(events);
  }

  Future<void> markAllRead() async {
    await _repo.markAllRead();
    await refresh();
  }

  Future<void> markRead(String id) async {
    await _repo.markRead(id);
    await refresh();
  }

  Future<void> clear() async {
    await _repo.clear();
    state = const AsyncValue.data(<AlertEvent>[]);
  }

  /// Inject a different repository instance for testing.
  // ignore: avoid_setters_without_getters
  set debugRepository(AlertHistoryRepository repo) => _repo = repo;
}

final alertHistoryProvider =
    AsyncNotifierProvider<AlertHistoryNotifier, List<AlertEvent>>(
  AlertHistoryNotifier.new,
);

/// Derived: groups history into HOY / AYER / ANTERIORES based on the device's
/// local calendar day. Returns the same loading/error states as the source.
final groupedAlertHistoryProvider =
    Provider<AsyncValue<AlertHistoryGroups>>((ref) {
  final history = ref.watch(alertHistoryProvider);
  return history.whenData((events) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayList = <AlertEvent>[];
    final yesterdayList = <AlertEvent>[];
    final earlierList = <AlertEvent>[];

    for (final event in events) {
      final local = event.firedAt.toLocal();
      final eventDay = DateTime(local.year, local.month, local.day);
      if (eventDay == today) {
        todayList.add(event);
      } else if (eventDay == yesterday) {
        yesterdayList.add(event);
      } else {
        earlierList.add(event);
      }
    }

    return (
      today: List<AlertEvent>.unmodifiable(todayList),
      yesterday: List<AlertEvent>.unmodifiable(yesterdayList),
      earlier: List<AlertEvent>.unmodifiable(earlierList),
    );
  });
});

/// Derived: count of unread events. Returns 0 while loading or on error.
final unreadAlertCountProvider = Provider<int>((ref) {
  final history = ref.watch(alertHistoryProvider);
  return history.maybeWhen(
    data: (events) => events.where((e) => !e.read).length,
    orElse: () => 0,
  );
});
