import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:news_tracker/model/tracked_term.dart';
import 'package:news_tracker/utils/new_notifications/initialize_notifications.dart';
import 'package:news_tracker/utils/new_notifications/notification_details.dart';
import 'package:news_tracker/utils/tz_convert.dart';

// TODO: Finish this function, replace all current notification functions except initialization
Future<void> scheduleNotificationFromTerm(TrackedTerm term,
    FlutterLocalNotificationsPlugin? plugin,) async {
  final details = defaultAndroidDetails;

  if (term.notificationTime == null) {
    return;
  }
  final scheduled = timeOfDayToTzDateTime(term.notificationTime!);

  final _plugin = plugin ?? notificationsPlugin;

  final payloadMap = <String, dynamic>{
    'data': term.term,
    'scheduledAt': scheduled.toUtc().toIso8601String(),
  };
  final payloadJson = jsonEncode(payloadMap);

  final pending = await _plugin.pendingNotificationRequests();

  throw UnimplementedError();
}
