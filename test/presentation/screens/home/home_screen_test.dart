import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_tracker/presentation/screens/home/home_screen.dart';
import 'package:news_tracker/presentation/screens/home/term_inputs_widget.dart';
import 'package:news_tracker/presentation/screens/home/terms_list_container_widget.dart';
import 'package:news_tracker/presentation/shared_widgets/app_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('HomeScreen correctly displays main UI elements', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: HomeScreen(showPermissionDialog: false)),
      ),
    );

    expect(find.byType(DefaultBar), findsOneWidget);
    // expect(find.byType(OptionsDrawer), findsOneWidget);
    expect(find.byType(TermsListContainer), findsOneWidget);

    final termInput = find.byType(TermInput);
    expect(termInput, findsOneWidget);
  });

  testWidgets('TermInput correctly adds a term', (WidgetTester tester) async {
    const newTerm = 'retinitis pigmentosa';

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: HomeScreen(showPermissionDialog: false)),
      ),
    );

    final textFieldFinder = find.descendant(
      of: find.byType(TermInput),
      matching: find.byType(TextField),
    );

    expect(textFieldFinder, findsOneWidget);

    await tester.enterText(textFieldFinder, newTerm);
    await tester.pumpAndSettle();

    final addButtonFinder = find.descendant(
      of: find.byType(TermInput),
      matching: find.widgetWithText(ElevatedButton, 'Add'),
    );

    expect(addButtonFinder, findsOneWidget);

    await tester.tap(addButtonFinder);
    await tester.pumpAndSettle();

    expect(find.text(newTerm), findsOneWidget);
  });
}
