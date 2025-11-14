import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_tracker/utils/tz_convert.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    final local = tz.getLocation('America/New_York');
    tz.setLocalLocation(local);
  });

  test('timeOfDayToTzDateTime converts correctly', () {
    final now = tz.TZDateTime.now(tz.local);
    final expected = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      8,
      30,
      0,
    );
    final actual = timeOfDayToTzDateTime(TimeOfDay(hour: 8, minute: 30));
    expect(actual, expected);
  });
}
