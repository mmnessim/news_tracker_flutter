import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:news_tracker/utils/notifications/initialize_notifications.dart';
import 'package:news_tracker/utils/notifications/pending_notifications.dart';
import 'package:news_tracker/utils/notifications/schedule_notifications.dart';
import 'package:news_tracker/utils/preferences.dart';
import 'package:news_tracker/utils/tz_convert.dart';

import 'notification_spec.dart';

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

Future<void> clearAndRescheduleNotifications() async {
  await cancelAllNotifications();
  final terms = await loadSearchTerms();
  for (var term in terms) {
    final spec = NotificationSpec(
      id: terms.indexOf(term),
      title: 'New results for $term',
      body: 'Tap here to see new results',
      payload: term,
      timeOfDay: await loadNotificationTime() ?? TimeOfDay.now(),
      exactDate: timeOfDayToTzDateTime(
        await loadNotificationTime() ?? TimeOfDay.now(),
      ),
    );
    await scheduleNotificationWithId(spec, notificationsPlugin);
  }
}
