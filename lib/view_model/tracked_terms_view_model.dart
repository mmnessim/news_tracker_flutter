import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:news_tracker/model/tracked_term.dart';
import 'package:news_tracker/repositories/tracked_term_repository.dart';
import 'package:news_tracker/utils/notifications/notification_spec.dart';
import 'package:news_tracker/utils/notifications/schedule_notifications.dart';
import 'package:news_tracker/utils/preferences.dart';
import 'package:news_tracker/utils/tz_convert.dart';

final trackedTermsRepositoryProvider = Provider<TrackedTermsRepository>(
  (ref) => TrackedTermsRepository(),
);

final trackedTermsViewModelProvider =
    StateNotifierProvider.autoDispose<
      TrackedTermsViewModel,
      AsyncValue<List<TrackedTerm>>
    >((ref) {
      final repo = ref.read(trackedTermsRepositoryProvider);
      final vm = TrackedTermsViewModel(repo);
      vm.load();
      return vm;
    });

class TrackedTermsViewModel
    extends StateNotifier<AsyncValue<List<TrackedTerm>>> {
  final TrackedTermsRepository _repo;

  TrackedTermsViewModel(this._repo) : super(const AsyncValue.loading());

  Future<void> load() async {
    state = AsyncValue.loading();
    try {
      final items = await _repo.fetchAll();
      state = AsyncValue.data(items);
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }

  Future<void> add(TrackedTerm term) async {
    final prev = state;
    state = const AsyncValue.loading();
    try {
      await _repo.add(term);
      final time = await loadNotificationTime();

      await scheduleNotificationWithId(
        NotificationSpec(
          id: term.id,
          title: 'News for ${term.term}',
          body: 'Tap to see details',
          payload: term.term,
          timeOfDay: time,
        ),
        null,
      );
      final items = await _repo.fetchAll();
      state = AsyncValue.data(items);
    } catch (err, stack) {
      print(err);
      state = prev;
      state = AsyncValue.error(err, stack);
    }
  }

  Future<void> remove(int id) async {
    final prev = state;
    state = const AsyncValue.loading();
    try {
      await _repo.remove(id);
      final items = await _repo.fetchAll();
      state = AsyncValue.data(items);
    } catch (err, stack) {
      state = prev;
    }
  }
}
