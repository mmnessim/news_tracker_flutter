import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'initialize_notifications.dart';

final _notificationRescheduleController = StreamController<int>.broadcast();

Stream<int> get notificationRescheduleStream =>
    _notificationRescheduleController.stream;

void notifyNotificationReschedule(int id) {
  if (!_notificationRescheduleController.isClosed) {
    _notificationRescheduleController.add(id);
  }
}

void disposeNotificationRescheduleController() {
  _notificationRescheduleController.close();
}

Future<List<PendingNotificationRequest>> getPendingNotifications() async {
  return await notificationsPlugin.pendingNotificationRequests();
}

Future<PendingNotificationRequest?> getNotificationById(int id) async {
  final pending = await getPendingNotifications();
  try {
    return pending.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
}

Future<void> cancelAllNotifications(
  FlutterLocalNotificationsPlugin? plugin,
) async {
  final _plugin = plugin ?? notificationsPlugin;
  await _plugin.cancelAll();
}
