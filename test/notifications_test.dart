import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:news_tracker/utils/notifications/show_notification.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
    tz.setLocalLocation(tz.getLocation('UTC'));

    // register fallback values for mocktail for non-primitive types
    registerFallbackValue(tz.TZDateTime.now(tz.UTC));
    registerFallbackValue(
      const NotificationDetails(
        android: AndroidNotificationDetails('fallback', 'fallback'),
      ),
    );
    registerFallbackValue(AndroidScheduleMode.exact);
  });

  test(
    'scheduleNotificationWithId calls zonedSchedule with expected args',
    () async {
      final mockPlugin = MockFlutterLocalNotificationsPlugin();

      // stub any zonedSchedule call to succeed
      when(
        () => mockPlugin.zonedSchedule(
          any(),
          any(),
          any(),
          any(),
          any(),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          payload: any(named: 'payload'),
        ),
      ).thenAnswer((_) async {});

      final scheduled = tz.TZDateTime.now(
        tz.UTC,
      ).add(const Duration(minutes: 5));
      final spec = NotificationSpec(
        id: 99,
        title: 'Test Title',
        body: 'Test Body',
        payload: 'test-payload',
        exactDate: scheduled,
        repeat: null,
      );

      await scheduleNotificationWithId(spec, mockPlugin);

      verify(
        () => mockPlugin.zonedSchedule(
          99,
          'Test Title',
          'Test Body',
          scheduled,
          any(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: 'test-payload',
        ),
      ).called(1);
    },
  );
}
