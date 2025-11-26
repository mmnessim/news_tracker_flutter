import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:news_tracker/utils/new_notifications/initialize_notifications.dart';
import 'package:news_tracker/utils/notifications/pending_notifications.dart';
import 'package:news_tracker/utils/notifications/schedule_notifications.dart';
import 'package:news_tracker/utils/preferences.dart';
import 'package:news_tracker/utils/tz_convert.dart';

import 'notification_spec.dart';

// TODO: Probably needs to be reworked due to TrackedTerm rework
Future<void> clearAndRescheduleNotifications({
  FlutterLocalNotificationsPlugin? plugin,
  Future<List<String>> Function()? searchTermsLoader,
}) async {
  final _plugin = plugin ?? notificationsPlugin;
  final loader = searchTermsLoader ?? loadSearchTerms;
  await cancelAllNotifications(_plugin);
  final terms = await loader();
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
    // notifyNotificationReschedule(terms.indexOf(term));
    await scheduleNotificationWithId(spec, _plugin);
  }
}

Future<void> clearAndRescheduleById(FlutterLocalNotificationsPlugin? plugin,
    TimeOfDay time,
    int id,) async {
  final _plugin = plugin ?? notificationsPlugin;
  final pending = await getPendingNotifications();
  final n = pending.firstWhere((n) => n.id == id);
  final newNotification = NotificationSpec(
    id: id,
    title: n.title!,
    body: n.body!,
    timeOfDay: time,
    payload: n.payload,
    exactDate: timeOfDayToTzDateTime(time),
  );
  _plugin.cancel(n.id);
  scheduleNotificationWithId(newNotification, _plugin);
}
