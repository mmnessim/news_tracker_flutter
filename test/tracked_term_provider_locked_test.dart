import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_tracker/model/tracked_term.dart';
import 'package:news_tracker/providers/tracked_term_provider_locked.dart';
import 'package:news_tracker/utils/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockNotificationHelpers {
  Future<void> cancelNotificationByTerm(
    TrackedTerm term,
    dynamic plugin,
  ) async {}

  Future<void> releaseNotificationId(int id) async {}
}

void main() {
  late MockSharedPreferences mockSharedPreferences;

  final term1 = TrackedTerm(
    id: 'id-1',
    term: 'Flutter',
    notificationId: 101,
    locked: false,
    notificationTime: const TimeOfDay(hour: 9, minute: 0),
  );
  final term2 = TrackedTerm(
    id: 'id-2',
    term: 'Riverpod',
    notificationId: 102,
    locked: true,
    notificationTime: const TimeOfDay(hour: 10, minute: 30),
  );

  final termsAsJsonStrings = [
    jsonEncode(term1.toJson()),
    jsonEncode(term2.toJson()),
  ];

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();

    registerFallbackValue(term1);
    registerFallbackValue(101);
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        // Wrap the mock object in AsyncValue.data to match the FutureProvider's output type
        sharedPrefsProvider.overrideWith(
          (ref) => Future.value(mockSharedPreferences),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('TrackedTermNotifierLocked Tests', () {
    test(
      'build method correctly loads and deserializes terms from preferences',
      () async {
        // ARRANGE: Set up the mock to return our test data
        when(
          () => mockSharedPreferences.getStringList('searchTerms'),
        ).thenReturn(termsAsJsonStrings);
        when(
          () => mockSharedPreferences.getString('notificationTime'),
        ).thenReturn(null);

        final container = createContainer();

        final result = await container.read(newTrackedTermsProvider.future);

        expect(result.length, 2);
        expect(result.first.term, 'Flutter');
        expect(result.last.term, 'Riverpod');
      },
    );
  });
}
