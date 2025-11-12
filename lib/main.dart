import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:news_tracker/about.dart';
import 'package:news_tracker/utils/initialize_notifications.dart';
import 'package:news_tracker/utils/preferences.dart';
import 'package:news_tracker/utils/show_notification.dart';
import 'package:news_tracker/widgets/time_picker_row.dart';
// import 'package:news_tracker/utils/show_notification.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'widgets/add_news_item.dart';
import 'widgets/page_body_container.dart';
import 'widgets/tracked_terms_list.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<bool> initializeApp(GlobalKey<NavigatorState> navigatorKey) async {
  await dotenv.load();
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

/// Entry point for the News Tracker app.
/// Loads environment variables and runs the app.
Future<void> main() async {
  bool showPermissionDialog = await initializeApp(navigatorKey);
  runApp(MyApp(showPermissionDialog: showPermissionDialog));
}

/// The root widget for the News Tracker app.
class MyApp extends StatelessWidget {
  final bool showPermissionDialog;

  /// Creates the News Tracker app.
  const MyApp({super.key, required this.showPermissionDialog});

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
        title: 'News Tracker',
        showPermissionDialog: showPermissionDialog,
      ),
    );
  }
}

/// The main home page for News Tracker.
class MyHomePage extends StatefulWidget {
  /// The title displayed in the app bar.
  final String title;
  final bool showPermissionDialog;

  /// Creates the home page.
  const MyHomePage({
    super.key,
    required this.title,
    required this.showPermissionDialog,
  });

  /// Creates the mutable state for this widget.
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// State for [MyHomePage].
class _MyHomePageState extends State<MyHomePage> {
  /// List of tracked search terms.
  final List<String> _searchTerms = [];

  /// Loads search terms from preferences when the widget is initialized.
  @override
  void initState() {
    super.initState();
    if (widget.showPermissionDialog) {
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
    loadSearchTerms().then((terms) {
      setState(() {
        _searchTerms.addAll(terms);
      });
    });
  }

  /// Adds a new search term and saves the updated list.
  void _addSearchTerm(String term) async {
    setState(() {
      _searchTerms.add(term);
    });
    saveSearchTerms(_searchTerms);
    int index = _searchTerms.indexOf(term);
    NotificationSpec spec = NotificationSpec(
      id: index,
      title: 'New results for $term',
      body: 'Tap here to see new results',
      payload: term,
    );
    await scheduleNotificationWithId(spec, null);
  }

  /// Removes a search term and saves the updated list.
  void _removeSearchTerm(String term) {
    setState(() {
      _searchTerms.remove(term);
    });
    saveSearchTerms(_searchTerms);
  }

  /// Builds the main UI for the home page, including the app bar, drawer, and body.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(widget.title),
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
          TimePickerRow(),
          Expanded(
            child: TrackedTermsList(
              terms: _searchTerms,
              onButtonClicked: _removeSearchTerm,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: AddNewsItem(onSearchTermAdded: _addSearchTerm),
          ),
        ],
      ),
    );
  }
}
