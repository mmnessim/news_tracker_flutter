import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:news_tracker/utils/notifications/initialize_notifications.dart';
import 'package:news_tracker/utils/notifications/notification_details.dart';
import 'package:timezone/timezone.dart' as tz;

import 'notification_helpers.dart';
import 'notification_spec.dart';

@Deprecated('Use scheduleNotificationFromTerm instead')
Future<void> scheduleNotificationWithId(
  NotificationSpec notificationSpec,
  FlutterLocalNotificationsPlugin? plugin,
) async {
  final details = defaultAndroidDetails;

  final scheduled =
      notificationSpec.exactDate ??
      (notificationSpec.timeOfDay != null
          ? nextInstanceOfTimeOfDay(notificationSpec.timeOfDay!)
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
}
