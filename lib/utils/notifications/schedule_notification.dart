import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/model/tracked_term.dart';
import 'package:news_tracker/providers/tracked_term_provider_locked.dart';
import 'package:news_tracker/utils/notifications/initialize_notifications.dart';
import 'package:news_tracker/utils/notifications/notification_details.dart';
import 'package:news_tracker/utils/notifications/notification_id.dart';
import 'package:news_tracker/utils/tz_convert.dart';

Future<void> scheduleNotificationFromTerm(
  TrackedTerm term,
  FlutterLocalNotificationsPlugin? plugin,
) async {
  final details = defaultAndroidDetails;

  // Schedule notification for 10 seconds from now if no time set
  final scheduled = (term.notificationTime != null)
      ? timeOfDayToTzDateTime(term.notificationTime!)
      : timeOfDayToTzDateTime(TimeOfDay.now()).add(Duration(seconds: 10));

  final _plugin = plugin ?? notificationsPlugin;

  // TODO: review what's in payloadMap and change as needed
  // final payloadMap = <String, dynamic>{
  //   'data': term.term,
  //   'scheduledAt': term.notificationTime,
  // };
  // final payloadJson = jsonEncode(payloadMap);

  final pending = await _plugin.pendingNotificationRequests();
  final alreadyScheduled = pending.any((n) => n.id == term.notificationId);
  if (alreadyScheduled) {
    await _plugin.cancel(term.notificationId);
  }

  await _plugin.zonedSchedule(
    term.notificationId,
    'New results for ${term.term}',
    'Tap here to see more',
    scheduled,
    details,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time,
    payload: term.term,
  );
}

Future<void> cancelNotificationByTerm(
  TrackedTerm term,
  FlutterLocalNotificationsPlugin? plugin,
) async {
  final _plugin = plugin ?? notificationsPlugin;
  await _plugin.cancel(term.notificationId);
}

Future<void> rescheduleAllNotifications(
  WidgetRef ref,
  FlutterLocalNotificationsPlugin? plugin,
) async {
  final _plugin = plugin ?? notificationsPlugin;
  final terms = await ref.read(newTrackedTermsProvider.future);
  try {
    for (final term in terms) {
      if (term.locked) {
        continue;
      }
      await _plugin.cancel(term.notificationId);
      final newTerm = term.copyWith(
        notificationId: await getNextNotificationId(),
      );
      await scheduleNotificationFromTerm(newTerm, _plugin);
      await ref
          .read(newTrackedTermsProvider.notifier)
          .updateTerm(term, term.notificationId);
      // await ref.read(newTrackedTermsProvider.notifier).add(term);
    }
  } catch (e) {
    print('Error rescheduling $e');
  }
}
