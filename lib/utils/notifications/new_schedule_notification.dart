import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/model/tracked_term.dart';
import 'package:news_tracker/providers/tracked_term_provider_locked.dart';
import 'package:news_tracker/utils/notifications/initialize_notifications.dart';
import 'package:news_tracker/utils/notifications/notification_details.dart';
import 'package:news_tracker/utils/tz_convert.dart';

import 'notification_helpers.dart';

class Scheduler {
  FlutterLocalNotificationsPlugin plugin;

  Scheduler({required this.plugin});

  Future<void> scheduleOne(TrackedTerm term) async {
    if (term.locked) return;
    if (term.notificationTime == null) return;

    final pending = await plugin.pendingNotificationRequests();
    // Check for already scheduled and cancel
    final alreadyScheduled = pending.any((n) => n.id == term.notificationId);
    if (alreadyScheduled) {
      await plugin.cancel(term.notificationId);
    }

    await _schedule(term);
  }

  Future<void> cancelOne(TrackedTerm term) async {
    if (term.locked) return;
    await releaseNotificationId(term.notificationId);
    await plugin.cancel(term.notificationId);
  }

  Future<void> updateOne(TrackedTerm term, int oldNotificationId) async {
    if (term.locked) return;
    if (term.notificationTime == null) return;

    await releaseNotificationId(term.notificationId);
    plugin.cancel(oldNotificationId);
    _schedule(term);
  }

  /// Calculates scheduled and calls plugin.zonedSchedule
  Future<void> _schedule(TrackedTerm term) async {
    final scheduled = timeOfDayToTzDateTime(term.notificationTime!);

    await plugin.zonedSchedule(
      term.notificationId,
      'New results for ${term.term}',
      'Tap here to see more',
      scheduled,
      defaultAndroidDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: term.term,
    );
  }
}

Future<void> scheduleNotificationFromTerm(
  TrackedTerm term,
  FlutterLocalNotificationsPlugin? plugin,
) async {
  final details = defaultAndroidDetails;

  if (term.locked) {
    return;
  }

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
        print('Term: ${term.term} is locked');
        continue;
      }
      await _plugin.cancel(term.notificationId);
      final newTerm = term.copyWith(
        notificationId: await getNextNotificationId(),
      );
      await ref
          .read(newTrackedTermsProvider.notifier)
          .updateTerm(term, term.notificationId);

      await scheduleNotificationFromTerm(newTerm, _plugin);

      // await ref.read(newTrackedTermsProvider.notifier).add(term);
    }
  } catch (e) {
    print('Error rescheduling $e');
  }
}
