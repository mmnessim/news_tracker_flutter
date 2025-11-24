import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/utils/notifications/reschedule_notifications.dart';
import 'package:news_tracker/utils/preferences.dart';

import '../utils/notifications/notification_spec.dart';
import '../utils/notifications/schedule_notifications.dart';
import '../utils/tz_convert.dart';

@Deprecated('Use TrackedTermNotifierLocked instead')
class TrackedTermNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    final terms = await loadSearchTerms();
    return terms;
  }

  Future<void> add(String term) async {
    final current = state.value ?? [];
    final updated = [...current, term];
    await saveSearchTerms(updated);
    state = AsyncValue.data(updated);

    if (state.value == null) {
      return;
    }

    final time = await loadNotificationTime() ?? TimeOfDay.now();
    final index = state.value!.indexOf(term);
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
    final current = state.value ?? [];
    final updated = current.where((t) => t != term).toList();
    // state = state.where((t) => t != term).toList();
    await saveSearchTerms(updated);
    state = AsyncValue.data(updated);
    await clearAndRescheduleNotifications();
  }
}

@Deprecated(
  'Use newTrackedTermsProvider instead. trackedTermsProvider will be removed in future updates',
)
final trackedTermsProvider =
    AsyncNotifierProvider<TrackedTermNotifier, List<String>>(
      TrackedTermNotifier.new,
    );
