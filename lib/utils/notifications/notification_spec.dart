import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../model/tracked_term.dart';
import 'notification_helpers.dart';

class NotificationSpec {
  final int id;
  final String title;
  final String body;
  final String? payload;
  final TimeOfDay? timeOfDay;
  final tz.TZDateTime? exactDate;
  final DateTimeComponents? repeat;
  final bool locked;

  NotificationSpec({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
    this.timeOfDay,
    this.exactDate,
    this.repeat,
    this.locked = false,
  });

  NotificationSpec copyWith({
    int? id,
    String? title,
    String? body,
    String? payload,
    TimeOfDay? timeOfDay,
    tz.TZDateTime? exactDate,
    DateTimeComponents? repeat,
    bool? locked,
  }) {
    return NotificationSpec(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      payload: payload ?? this.payload,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      exactDate: exactDate ?? this.exactDate,
      repeat: repeat ?? this.repeat,
      locked: locked ?? this.locked,
    );
  }

  static NotificationSpec fromTerm({required TrackedTerm term}) {
    return NotificationSpec(
      id: term.notificationId,
      title: 'New results for ${term.term}',
      body: 'Tap here to see results',
      payload: term.term,
      timeOfDay: term.notificationTime,
      exactDate: term.notificationTime != null
          ? nextInstanceOfTimeOfDay(term.notificationTime!)
          : null,
      repeat: DateTimeComponents.time,
      locked: term.locked,
    );
  }
}
