import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

tz.TZDateTime timeOfDayToTzDateTime(TimeOfDay time) {
  final now = tz.TZDateTime.now(tz.local);
  return tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
  );
}
