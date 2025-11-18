import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/utils/notifications/reschedule_notifications.dart';
import 'package:news_tracker/utils/preferences.dart';

class NotificationTimeNotifier extends AsyncNotifier<TimeOfDay?> {
  @override
  Future<TimeOfDay?> build() async {
    final time = await loadNotificationTime();
    return time;
  }

  Future<void> setNewTime(TimeOfDay newTime) async {
    state = AsyncValue.data(newTime);
    await saveNotificationTime(newTime);

    // TODO: Evaluate whether this needs to be called here
    await clearAndRescheduleNotifications();
  }
}

final notificationTimeProvider =
    AsyncNotifierProvider<NotificationTimeNotifier, TimeOfDay?>(
      NotificationTimeNotifier.new,
    );
