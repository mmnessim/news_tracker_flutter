import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:news_tracker/utils/notifications/initialize_notifications.dart';
import 'package:news_tracker/utils/preferences.dart';
import 'package:timezone/timezone.dart' as tz;

Future<void> showNotification(String title, String body) async {
  final TimeOfDay? notificationTime = await loadNotificationTime();

  final now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledTime;

  if (notificationTime != null) {
    scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      notificationTime.hour,
      notificationTime.minute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(Duration(days: 1));
    }
  } else {
    scheduledTime = now.add(const Duration(seconds: 10));
  }

  const androidDetails = AndroidNotificationDetails(
    'default_channel',
    'Default',
    importance: Importance.max,
    priority: Priority.high,
  );
  const details = NotificationDetails(android: androidDetails);

  try {
    await notificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exact,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    print('[Notification] zonedSchedule call succeeded');
  } catch (e, stack) {
    print('[Notification] zonedSchedule call failed: $e');
    print(stack);
  }
}
