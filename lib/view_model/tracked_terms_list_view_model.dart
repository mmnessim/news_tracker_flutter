import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/model/tracked_term.dart';
import 'package:news_tracker/providers/notification_provider.dart';
import 'package:news_tracker/providers/tracked_term_provider_locked.dart';

class TrackedTermsState {
  final List<TrackedTerm> terms;
  final List<PendingNotificationRequest> pendingNotifications;
  TrackedTermsState({
    required this.terms,
    required this.pendingNotifications,
  });
}

class TrackedTermsListViewModel extends AsyncNotifier<TrackedTermsState> {
  Future<TrackedTermsState> _compose() async {
    final terms = await ref.watch(newTrackedTermsProvider.future);
    final notifications = await ref.read(notificationProvider.future);
    for (final term in terms) {
      print('Term: ${term.term}, Notification Time: ${term.notificationTime}');
    }
    return TrackedTermsState(terms: terms, pendingNotifications: notifications);
  }

  @override
  FutureOr<TrackedTermsState> build() {
    final initial = _compose();

    ref.listen(newTrackedTermsProvider, (_, __) async {
      state = AsyncValue.loading();
      state = AsyncValue.data(await _compose());
    });
    ref.listen(notificationProvider, (_, __) async {
      state = AsyncValue.loading();
      state = AsyncValue.data(await _compose());
    });

    return initial;
  }

  Future<void> addTrackedTerm(String term, bool locked) async {
    final repo = ref.read(newTrackedTermsProvider.notifier);
    await repo.add(term, locked);
    state = AsyncValue.loading();
    state = AsyncValue.data(await _compose());
  }

  Future<void> removeTrackedTerm(TrackedTerm term) async {
    final repo = ref.read(newTrackedTermsProvider.notifier);
    await repo.remove(term);
    state = AsyncValue.loading();
    state = AsyncValue.data(await _compose());
  }

  Future<void> toggleLocked(TrackedTerm term) async {
    final repo = ref.read(newTrackedTermsProvider.notifier);
    await repo.toggleLocked(term);
    state = AsyncValue.loading();
    state = AsyncValue.data(await _compose());
  }

  Future<void> updateNotificationTime(TrackedTerm term, TimeOfDay newTime) async {
    final notificationRepo = ref.read(notificationProvider.notifier);
    final termRepo = ref.read(newTrackedTermsProvider.notifier);

    // Update term with new notification time
    final updatedTerm = term.copyWith(notificationTime: newTime);
    await termRepo.updateTerm(updatedTerm, term.notificationId);
    await notificationRepo.addNotification(updatedTerm);
    state = AsyncValue.loading();
    state = AsyncValue.data(await _compose());
  }

  Future<void> rescheduleAllNotifications() async {
    final notificationRepo = ref.read(notificationProvider.notifier);
    await notificationRepo.rescheduleAllNotifications();

    state = AsyncValue.loading();
    state = AsyncValue.data(await _compose());
  }
}

final trackedTermsListViewModelProvider =
    AsyncNotifierProvider<TrackedTermsListViewModel, TrackedTermsState>(
        TrackedTermsListViewModel.new);