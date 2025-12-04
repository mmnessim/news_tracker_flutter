import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/model/tracked_term.dart';

import '../utils/notifications/notification_helpers.dart';
import '../utils/notifications/schedule_notification.dart';

class NotificationNotifier
    extends AsyncNotifier<List<PendingNotificationRequest>> {
  @override
  FutureOr<List<PendingNotificationRequest>> build() async {
    return await getPendingNotifications();
  }

  Future<void> addNotification(TrackedTerm term) async {
    // final pending = await getPendingNotifications();
    await scheduleNotificationFromTerm(term, null);
    state = AsyncValue.loading();
    state = AsyncValue.data(await getPendingNotifications());
  }

  Future<void> rescheduleAllNotifications() async {
    await rescheduleAllNotifications();
    state = AsyncValue.loading();
    state = AsyncValue.data(await getPendingNotifications());
  }
}

final notificationProvider =
    AsyncNotifierProvider<
      NotificationNotifier,
      List<PendingNotificationRequest>
    >(NotificationNotifier.new);
