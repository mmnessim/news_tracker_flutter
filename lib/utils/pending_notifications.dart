import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'initialize_notifications.dart';

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
