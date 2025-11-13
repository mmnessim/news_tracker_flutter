import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:news_tracker/details.dart';
import 'package:news_tracker/main.dart';
import 'package:news_tracker/widgets/add_news_item.dart';
import 'package:news_tracker/widgets/time_picker_row.dart';
import 'package:news_tracker/widgets/tracked_terms_list.dart';
import 'package:news_tracker/utils/convert_date.dart';

void main() {
  setUpAll(() async {
    await dotenv.load(fileName: '.env');
  });

  testWidgets(
    'MyApp home page renders core widgets and drawer navigation works',
    (WidgetTester tester) async {
      await tester.pumpWidget(const NewsTracker(showPermissionDialog: false));
      await tester.pumpAndSettle();

      // Check for app bar title
      expect(find.text('News Tracker'), findsOneWidget);

      // Check for TimePickerRow
      expect(find.byType(TimePickerRow), findsOneWidget);

      // Check for TrackedTermsList
      expect(find.byType(TrackedTermsList), findsOneWidget);

      // Check for AddNewsItem
      expect(find.byType(AddNewsItem), findsOneWidget);

      // Open drawer
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();

      // Tap About and navigate
      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();

      // Check About page is shown (adjust text as needed)
      expect(
        find.text('About'),
        findsWidgets,
      ); // Use the actual About page text
    },
  );

  testWidgets('Add search term adds search term', (WidgetTester tester) async {
    List<String> terms = [];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  AddNewsItem(
                    onSearchTermAdded: (term) {
                      setState(() {
                        terms.add(term);
                      });
                    },
                  ),
                  TrackedTermsList(
                    terms: terms,
                    onButtonClicked: (_) {}, // No-op for test
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    // Enter a search term in the AddNewsItem's TextField
    const testTerm = 'flutter';
    await tester.enterText(find.byType(TextField), testTerm);

    // Tap the button with text 'Track New Term'
    await tester.tap(find.text('Track New Term'));
    await tester.pump();

    // Verify the term appears in the tracked terms list
    expect(find.text(testTerm), findsOneWidget);
  });

  testWidgets('Remove button removes item', (WidgetTester tester) async {
    List<String> terms = ['one'];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return TrackedTermsList(
                terms: terms,
                onButtonClicked: (term) {
                  setState(() {
                    terms.remove(term);
                  });
                },
              );
            },
          ),
        ),
      ),
    );

    // Verify the term is present
    expect(find.text('one'), findsOneWidget);
    // print('Found "one"');

    await tester.tap(find.text('-'));
    await tester.pump();

    // Verify the term is removed
    expect(find.text('one'), findsNothing);
    // print('Found nothing, as expected');
  });

  testWidgets('Shows permission dialog when permission is denied', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NewsTracker(showPermissionDialog: true));
    await tester.pumpAndSettle();

    expect(find.text('Notification Permission'), findsOneWidget);
    expect(find.textContaining('permanently denied'), findsOneWidget);

    // Tap OK to dismiss
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Notification Permission'), findsNothing);
  });

  testWidgets('Drawer navigation to About page', (WidgetTester tester) async {
    await tester.pumpWidget(const NewsTracker(showPermissionDialog: false));

    // Open drawer
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    // Tap About
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();

    expect(find.text('About'), findsOneWidget);
  });

  testWidgets('TimePickerRow opens time picker', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: TimePickerRow())));

    await tester.tap(find.text('Select Notification Time'));
    await tester.pumpAndSettle();

    // The time picker dialog should appear
    expect(find.byType(TimePickerDialog), findsOneWidget);
  });

  testWidgets('DetailsPage shows loading, results.', (
    WidgetTester tester,
  ) async {
    // Success case
    final mockClientSuccess = MockClient((request) async {
      return http.Response('''
      {
        "status": "ok",
        "totalResults": 1,
        "articles": [
          {
            "source": {"id": null, "name": "Test Source"},
            "author": "Test Author",
            "title": "Test Article",
            "description": "Test Desc",
            "url": "http://test.com",
            "urlToImage": "http://test.com/image.jpg",
            "publishedAt": "2025-11-10T12:00:00Z",
            "content": "Test Content"
          }
        ]
      }
    ''', 200);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: DetailsPage(term: 'success', client: mockClientSuccess),
      ),
    );

    expect(find.text('Loading...'), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.textContaining('Results'), findsOneWidget);
    expect(find.text('Test Article'), findsOneWidget);
  });

  testWidgets('DetailsPage error state works correctly', (
    WidgetTester tester,
  ) async {
    final mockClientError = MockClient((request) async {
      return http.Response('Not found', 404);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: DetailsPage(
          key: ValueKey('fail'), // <= add key to force new State
          term: 'fail',
          client: mockClientError,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('404'), findsNWidgets(2));
  });

  test('formatDate correctly formats date', () {
    const isoDate = '2025-11-11';
    final formatted = formatDate(isoDate);
    expect(formatted, equals('November 11, 2025'));
  });
}
