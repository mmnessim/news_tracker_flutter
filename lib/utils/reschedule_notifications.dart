import 'dart:convert';

import 'package:news_tracker/utils/initialize_notifications.dart';
import 'package:news_tracker/utils/pending_notifications.dart';
import 'package:news_tracker/utils/preferences.dart';
import 'package:news_tracker/utils/show_notification.dart';
import 'package:news_tracker/utils/tz_convert.dart';

Future<void> rescheduleAllNotifications() async {
  final pending = await getPendingNotifications();
  if (pending.isEmpty) return;
  final notificationTime = await loadNotificationTime();
  if (notificationTime == null) return;

  for (var p in pending) {
    String payloadString = '';
    if (p.payload != null && p.payload!.isNotEmpty) {
      try {
        final decoded = jsonDecode(p.payload!);
        if (decoded is Map && decoded.containsKey('data')) {
          payloadString = decoded['data']?.toString() ?? '';
        } else {
          payloadString = p.payload!;
        }
      } catch (_) {
        payloadString = p.payload!;
      }
    }

    final spec = NotificationSpec(
      id: p.id,
      title: p.title ?? '',
      body: p.body ?? '',
      payload: payloadString,
      timeOfDay: notificationTime,
      exactDate: timeOfDayToTzDateTime(notificationTime),
    );
    scheduleNotificationWithId(spec, notificationsPlugin);
  }
}
