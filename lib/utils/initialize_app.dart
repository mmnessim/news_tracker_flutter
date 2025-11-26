import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:news_tracker/utils/notifications/initialize_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<bool> initializeApp(GlobalKey<NavigatorState> navigatorKey) async {
  try {
    await dotenv.load();
  } catch (_) {
    print('No .env file found');
  }
  WidgetsFlutterBinding.ensureInitialized();
  await initializeNotifications(navigatorKey);
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/New_York'));

  var notificationPermission = await Permission.notification.status;
  if (notificationPermission.isDenied) {
    await Permission.notification.request();
    return false;
  } else if (notificationPermission.isPermanentlyDenied) {
    return true;
  }
  return false;
}
