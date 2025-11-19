import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:news_tracker/model/tracked_term.dart';
import 'package:news_tracker/repositories/tracked_term_repository.dart';

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
      final items = await _repo.fetchAll();
      state = AsyncValue.data(items);
    } catch (err, stack) {
      state = prev;
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
