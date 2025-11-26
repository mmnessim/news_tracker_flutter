import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/utils/new_notifications/pending_notifications.dart';

class NotificationNotifier
    extends AsyncNotifier<List<PendingNotificationRequest>> {
  @override
  FutureOr<List<PendingNotificationRequest>> build() async {
    return await getPendingNotifications();
  }
}

final notificationProvider =
    AsyncNotifierProvider<
      NotificationNotifier,
      List<PendingNotificationRequest>
    >(NotificationNotifier.new);
