import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:news_tracker/utils/notifications/initialize_notifications.dart';
import 'package:news_tracker/utils/notifications/pending_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'notification_spec.dart';

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

  final payloadMap = <String, dynamic>{
    if (notificationSpec.payload != null) 'data': notificationSpec.payload,
    'scheduledAt': scheduled.toUtc().toIso8601String(),
  };
  final payloadJson = jsonEncode(payloadMap);

  final pending = await _plugin.pendingNotificationRequests();
  final alreadyScheduled = pending.any((n) => n.id == notificationSpec.id);
  if (alreadyScheduled) {
    await _plugin.cancel(notificationSpec.id);
  }

  await _plugin.zonedSchedule(
    notificationSpec.id,
    notificationSpec.title,
    notificationSpec.body,
    scheduled,
    details,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: notificationSpec.repeat ?? DateTimeComponents.time,
    payload: payloadJson,
  );
  notifyNotificationReschedule(notificationSpec.id);
}

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
