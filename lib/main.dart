import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/screens/home_screen.dart';
import 'package:news_tracker/utils/initialize_app.dart';
import 'package:news_tracker/utils/workmanager/task_handler.dart';
import 'package:workmanager/workmanager.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Entry point for the News Tracker app.
/// Loads environment variables and runs the app.
Future<void> main() async {
  bool showPermissionDialog = await initializeApp(navigatorKey);
  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerOneOffTask(
    'initial_check',
    'check_new_article',
    initialDelay: Duration(seconds: 10),
  );

  Workmanager().registerPeriodicTask(
    'regular_check',
    'check_new_article',
    frequency: Duration(hours: 12),
  );

  runApp(
    ProviderScope(
      child: NewsTracker(showPermissionDialog: showPermissionDialog),
    ),
  );
}

/// The root widget for the News Tracker app.
class NewsTracker extends StatelessWidget {
  final bool showPermissionDialog;

  /// Creates the News Tracker app.
  const NewsTracker({super.key, required this.showPermissionDialog});

  /// Builds the MaterialApp with theme and home page.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'News Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          surface: Color.fromARGB(237, 250, 240, 248),
        ),
      ),
      home: HomeScreen(showPermissionDialog: showPermissionDialog),
    );
  }
}
