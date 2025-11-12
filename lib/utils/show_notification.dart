import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:news_tracker/utils/initialize_notifications.dart';
import 'package:news_tracker/utils/preferences.dart';
import 'package:timezone/timezone.dart' as tz;

tz.TZDateTime _nextInstanceOfTimeOfDay(TimeOfDay time) {
  final now = tz.TZDateTime.now(tz.local);
  var scheduled = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
  );
  if (scheduled.isBefore(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}

class NotificationSpec {
  final int id;
  final String title;
  final String body;
  final String? payload;
  final TimeOfDay? timeOfDay;
  final tz.TZDateTime? exactDate;
  final DateTimeComponents? repeat;

  NotificationSpec({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
    this.timeOfDay,
    this.exactDate,
    this.repeat,
  });
}

Future<void> scheduleNotificationWithId(
  NotificationSpec notificationSpec,
  FlutterLocalNotificationsPlugin? plugin,
) async {
  final details = const NotificationDetails(
    android: AndroidNotificationDetails(
      'default_channel',
      'Default',
      importance: Importance.max,
      priority: Priority.high,
    ),
  );

  final scheduled =
      notificationSpec.exactDate ??
      (notificationSpec.timeOfDay != null
          ? _nextInstanceOfTimeOfDay(notificationSpec.timeOfDay!)
          : tz.TZDateTime.now(tz.local).add(Duration(seconds: 10)));

  final _plugin = plugin ?? notificationsPlugin;

  await _plugin.zonedSchedule(
    notificationSpec.id,
    notificationSpec.title,
    notificationSpec.body,
    scheduled,
    details,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: notificationSpec.repeat ?? DateTimeComponents.time,
    payload: notificationSpec.payload,
  );
}

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
