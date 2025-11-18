import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/about.dart';
import 'package:news_tracker/providers/tracked_term_provider.dart';
import 'package:news_tracker/utils/initialize_app.dart';
import 'package:news_tracker/widgets/time_picker_row.dart';

import 'widgets/page_body_container.dart';
import 'widgets/tracked_terms/add_tracked_term.dart';
import 'widgets/tracked_terms/tracked_terms_list.dart';

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
      home: MyHomePage(
        //title: 'News Tracker',
        showPermissionDialog: showPermissionDialog,
      ),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  final bool showPermissionDialog;

  const MyHomePage({required this.showPermissionDialog});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final terms = ref.watch(trackedTermsProvider);
    final termCount = terms.length;

    if (showPermissionDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Notification Permission'),
            content: Text(
              'Notification permission is permanently denied. NewsTracker will not work properly without notification permission. Visit your phone\'s Settings -> Apps -> NewsTracker -> Permissions to enable',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('News Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.access_time),
            tooltip: 'Set Notification Time',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Set Notification Time'),
                  content: TimePickerRow(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: PageBodyContainer(
        children: [
          Text('Term count: $termCount'),
          Expanded(
            child: TrackedTermsList(
              terms: terms,
              onButtonClicked: (String t) {
                ref.read(trackedTermsProvider.notifier).remove(t);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: AddTrackedTerm(
              onSearchTermAdded: (String t) {
                ref.read(trackedTermsProvider.notifier).add(t);
              },
            ),
          ),
        ],
      ),
    );
  }
}
