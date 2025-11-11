import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'default_channel', // id
  'Default', // name
  description: 'This channel is used for default notifications.',
  importance: Importance.defaultImportance,
);


Future<void> initializeNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(
    android: androidSettings,
    iOS: DarwinInitializationSettings(),
  );
  await notificationsPlugin.initialize(settings);

  await notificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Request exact alarm permission for Android 12+ (required for zonedSchedule with exact timing)
  final androidImplementation = notificationsPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  
  if (androidImplementation != null) {
    final canScheduleExact = await androidImplementation.canScheduleExactNotifications();
    print('[Notifications] Can schedule exact notifications: $canScheduleExact');
    
    if (canScheduleExact == false) {
      print('[Notifications] Requesting exact alarm permission...');
      await androidImplementation.requestExactAlarmsPermission();
    }
  }
}
