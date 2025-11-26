import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final defaultAndroidDetails = const NotificationDetails(
  android: AndroidNotificationDetails(
    'default_channel',
    'Default',
    importance: Importance.max,
    priority: Priority.high,
  ),
);
