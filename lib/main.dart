import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/screens/home_screen.dart';
import 'package:news_tracker/utils/initialize_app.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Entry point for the News Tracker app.
/// Loads environment variables and runs the app.
Future<void> main() async {
  bool showPermissionDialog = await initializeApp(navigatorKey);
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
