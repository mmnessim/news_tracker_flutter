import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:news_tracker/details.dart';
import 'package:news_tracker/utils/preferences.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'default_channel', // id
  'Default', // name
  description: 'This channel is used for default notifications.',
  importance: Importance.defaultImportance,
);

Future<void> initializeNotifications(
  GlobalKey<NavigatorState> navigatorKey,
) async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(
    android: androidSettings,
    iOS: DarwinInitializationSettings(),
  );

  //TODO: Refactor to pass TrackedTerm to DetailsPage
  await notificationsPlugin.initialize(
    settings,
    // onDidReceiveNotificationResponse: (details) {
    //   final payload = details.payload;
    //   if (payload != null && payload.isNotEmpty) {
    //     final map = jsonDecode(payload);
    //     if (map is Map && map['data'] is String) {
    //       final term = map['data'] as String;
    //       navigatorKey.currentState?.push(
    //         MaterialPageRoute(builder: (_) => DetailsPage(term: term)),
    //       );
    //     }
    //   }
    // },
  );

  // TODO: Refactor to pass TrackedTerm to DetailsPage
  final details = await notificationsPlugin.getNotificationAppLaunchDetails();
  // if (details != null && details.didNotificationLaunchApp) {
  //   final payload = details.notificationResponse?.payload;
  //   if (payload != null && payload.isNotEmpty) {
  //     final map = jsonDecode(payload);
  //     if (map is Map && map['data'] is String) {
  //       final term = map['data'] as String;
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         navigatorKey.currentState?.push(
  //           MaterialPageRoute(builder: (_) => DetailsPage(term: term)),
  //         );
  //       });
  //     }
  //   }
  // }
  await notificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  final androidImplementation = notificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  if (androidImplementation != null) {
    final canScheduleExact = await androidImplementation
        .canScheduleExactNotifications();
    print(
      '[Notifications] Can schedule exact notifications: $canScheduleExact',
    );

    if (canScheduleExact == false) {
      print('[Notifications] Requesting exact alarm permission...');
      await androidImplementation.requestExactAlarmsPermission();
    }
  }
}
