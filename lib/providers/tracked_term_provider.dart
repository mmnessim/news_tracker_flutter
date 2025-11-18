import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:news_tracker/utils/notifications/reschedule_notifications.dart';
import 'package:news_tracker/utils/preferences.dart';

import '../utils/notifications/notification_spec.dart';
import '../utils/notifications/schedule_notifications.dart';
import '../utils/tz_convert.dart';

class TrackedTermNotifier extends StateNotifier<List<String>> {
  TrackedTermNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    final terms = await loadSearchTerms();
    state = terms;
  }

  Future<void> add(String term) async {
    state = [...state, term];
    await saveSearchTerms(state);

    final time = await loadNotificationTime() ?? TimeOfDay.now();
    final index = state.indexOf(term);
    final spec = NotificationSpec(
      id: index,
      title: 'New results for $term',
      body: 'Tap here to see new results',
      payload: term,
      exactDate: timeOfDayToTzDateTime(time),
      timeOfDay: time,
    );

    await scheduleNotificationWithId(spec, null);
  }

  Future<void> remove(String term) async {
    state = state.where((t) => t != term).toList();
    await saveSearchTerms(state);
    await clearAndRescheduleNotifications();
  }
}

final trackedTermsProvider =
    StateNotifierProvider<TrackedTermNotifier, List<String>>(
      (ref) => TrackedTermNotifier(),
    );
