// language: dart
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/model/tracked_term.dart';
import 'package:news_tracker/providers/notification_provider.dart';
import 'package:news_tracker/providers/tracked_term_provider_locked.dart';
import 'package:news_tracker/utils/notifications/new_schedule_notification.dart';

class TrackedTermsState {
  final List<TrackedTerm> terms;
  final List<PendingNotificationRequest> pendingNotifications;

  TrackedTermsState({required this.terms, required this.pendingNotifications});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TrackedTermsState) return false;
    final listEq = const DeepCollectionEquality().equals;
    return listEq(terms, other.terms) &&
        listEq(pendingNotifications, other.pendingNotifications);
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(terms) ^
      const DeepCollectionEquality().hash(pendingNotifications);
}

class HomeScreenVM extends AsyncNotifier<TrackedTermsState> {
  late final TrackedTermNotifierLocked _termRepo;

  late final Scheduler _scheduler;

  Future<TrackedTermsState> _compose() async {
    final terms = await ref.watch(newTrackedTermsProvider.future);
    // final notifications = await ref.read(notificationProvider.future);
    final notifications = await _scheduler.getPending();
    return TrackedTermsState(terms: terms, pendingNotifications: notifications);
  }

  void _updateStateIfChanged(TrackedTermsState newState) {
    final current = state.asData?.value;
    if (current == newState) return;
    state = AsyncValue.data(newState);
  }

  @override
  FutureOr<TrackedTermsState> build() {
    final initial = _compose();
    _termRepo = ref.watch(newTrackedTermsProvider.notifier);
    _scheduler = ref.watch(schedulerProvider);

    ref.listen(newTrackedTermsProvider, (_, __) async {
      final newState = await _compose();
      _updateStateIfChanged(newState);
    });
    ref.listen(notificationProvider, (_, __) async {
      final newState = await _compose();
      _updateStateIfChanged(newState);
    });

    return initial;
  }

  Future<void> addTrackedTerm(String term, bool locked) async {
    try {
      await _termRepo.add(term, locked);
      final updatedTerms = await ref.read(newTrackedTermsProvider.future);
      final currentNotifications =
          state.asData?.value.pendingNotifications ??
          await ref.read(notificationProvider.future);
      _updateStateIfChanged(
        TrackedTermsState(
          terms: updatedTerms,
          pendingNotifications: currentNotifications!,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeTrackedTerm(TrackedTerm term) async {
    try {
      await _termRepo.remove(term);
      final updatedTerms = await ref.read(newTrackedTermsProvider.future);
      final currentNotifications =
          state.asData?.value.pendingNotifications ??
          await ref.read(notificationProvider.future);
      _updateStateIfChanged(
        TrackedTermsState(
          terms: updatedTerms,
          pendingNotifications: currentNotifications!,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleLocked(TrackedTerm term) async {
    try {
      await _termRepo.toggleLocked(term);
      final updatedTerms = await ref.read(newTrackedTermsProvider.future);
      final currentNotifications =
          state.asData?.value.pendingNotifications ??
          await ref.read(notificationProvider.future);
      _updateStateIfChanged(
        TrackedTermsState(
          terms: updatedTerms,
          pendingNotifications: currentNotifications!,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSingleNotificationTime(
    TrackedTerm term,
    TimeOfDay newTime,
  ) async {
    final updatedTerm = term.copyWith(notificationTime: newTime);
    await _termRepo.updateTerm(updatedTerm, term.notificationId);
    await _scheduler.scheduleOne(updatedTerm);
    final newState = await _compose();
    _updateStateIfChanged(newState);
  }

  Future<void> updateGlobalNotificationTime(TimeOfDay time) async {
    final allTerms = await _termRepo.getAllTerms();
    final updatedTerms = <TrackedTerm>[];
    for (final t in allTerms) {
      if (t.locked) {
        continue;
      }
      final newTerm = t.copyWith(notificationTime: time);
      updatedTerms.add(newTerm);
    }

    await _termRepo.updateMany(updatedTerms);
    await _scheduler.scheduleMany(updatedTerms);
    final newState = await _compose();
    state = AsyncValue.data(newState);
  }
}

final homeScreenVMProvider =
    AsyncNotifierProvider<HomeScreenVM, TrackedTermsState>(HomeScreenVM.new);
