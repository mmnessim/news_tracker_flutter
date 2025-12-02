// language: dart
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/model/tracked_term.dart';
import 'package:news_tracker/providers/notification_provider.dart';
import 'package:news_tracker/providers/tracked_term_provider_locked.dart';

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
  Future<TrackedTermsState> _compose() async {
    final terms = await ref.watch(newTrackedTermsProvider.future);
    final notifications = await ref.read(notificationProvider.future);
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
    final repo = ref.read(newTrackedTermsProvider.notifier);
    try {
      await repo.add(term, locked);
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
    final repo = ref.read(newTrackedTermsProvider.notifier);
    try {
      await repo.remove(term);
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
    final repo = ref.read(newTrackedTermsProvider.notifier);
    try {
      await repo.toggleLocked(term);
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

  Future<void> updateNotificationTime(
    TrackedTerm term,
    TimeOfDay newTime,
  ) async {
    final notificationRepo = ref.read(notificationProvider.notifier);
    final termRepo = ref.read(newTrackedTermsProvider.notifier);

    final updatedTerm = term.copyWith(notificationTime: newTime);
    await termRepo.updateTerm(updatedTerm, term.notificationId);
    await notificationRepo.addNotification(updatedTerm);

    final newState = await _compose();
    _updateStateIfChanged(newState);
  }

  Future<void> rescheduleAllNotifications() async {
    final notificationRepo = ref.read(notificationProvider.notifier);
    await notificationRepo.rescheduleAllNotifications();

    final newState = await _compose();
    _updateStateIfChanged(newState);
  }
}

final homeScreenVMProvider =
    AsyncNotifierProvider<HomeScreenVM, TrackedTermsState>(HomeScreenVM.new);
