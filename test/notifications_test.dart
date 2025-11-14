import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_tracker/utils/notifications/notification_spec.dart';
import 'package:news_tracker/utils/notifications/reschedule_notifications.dart';
import 'package:news_tracker/utils/notifications/schedule_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

void main() {
  // Initialize bindings so platform plugins (SharedPreferences, etc.) work in tests.
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
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

      // loosen payload expectation to `any` because implementation wraps payload into JSON
      verify(
        () => mockPlugin.zonedSchedule(
          99,
          'Test Title',
          'Test Body',
          scheduled,
          any(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: any(named: 'payload'),
        ),
      ).called(1);
    },
  );

  test('clearAndRescheduleNotifications cancels and reschedules', () async {
    final mockPlugin = MockFlutterLocalNotificationsPlugin();
    Future<List<String>> mockLoader() async => ['term1', 'term2'];

    when(() => mockPlugin.cancelAll()).thenAnswer((_) async {});
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

    await clearAndRescheduleNotifications(
      plugin: mockPlugin,
      searchTermsLoader: mockLoader,
    );

    verify(() => mockPlugin.cancelAll()).called(1);
    verify(
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
    ).called(2);
  });
}
