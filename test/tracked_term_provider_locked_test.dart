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
  TestWidgetsFlutterBinding.ensureInitialized();
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
        sharedPrefsProvider.overrideWith(
          (ref) => Future.value(mockSharedPreferences),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUpAll(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('TrackedTermNotifierLocked Tests', () {
    test(
      'build method correctly loads and deserializes terms from preferences',
      () async {
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

    test(
      'deserializeTermListHelper ignores invalid JSON and returns TrackedTerm list',
      () {
        final container = createContainer();
        final notifier = container.read(newTrackedTermsProvider.notifier);

        final jsonList = [
          jsonEncode(term1.toJson()),
          'not-a-json',
          jsonEncode(term2.toJson()),
        ];

        final result = notifier.deserializeTermListHelper(jsonList);

        expect(result.length, 2);
        expect(result[0].id, term1.id);
        expect(result[1].id, term2.id);
      },
    );

    test(
      'serializeTermListHelper encodes TrackedTerm list to JSON strings',
      () {
        final container = createContainer();
        final notifier = container.read(newTrackedTermsProvider.notifier);

        final input = [term1, term2];
        final result = notifier.serializeTermListHelper(input);

        expect(result.length, 2);

        final decoded0 = jsonDecode(result[0]) as Map<String, dynamic>;
        final decoded1 = jsonDecode(result[1]) as Map<String, dynamic>;

        expect(decoded0['id'], term1.id);
        expect(decoded1['id'], term2.id);
      },
    );

    test('toggleLocked flips locked flag and persists updated list', () async {
      when(
        () => mockSharedPreferences.getStringList('searchTerms'),
      ).thenReturn(termsAsJsonStrings);

      when(
        () => mockSharedPreferences.setStringList(
          'searchTerms',
          any<List<String>>(),
        ),
      ).thenAnswer((_) async => true);

      final container = createContainer();
      final notifier = container.read(newTrackedTermsProvider.notifier);

      await notifier.toggleLocked(term1);

      final updated = await container.read(newTrackedTermsProvider.future);
      expect(updated.length, 2);
      final updatedTerm = updated.firstWhere((t) => t.id == term1.id);
      expect(updatedTerm.locked, true);

      final captured = verify(
        () => mockSharedPreferences.setStringList(
          'searchTerms',
          captureAny<List<String>>(),
        ),
      ).captured;

      expect(captured.length, 1);
      final savedList = captured.first as List<String>;
      final decoded = jsonDecode(savedList.first) as Map<String, dynamic>;
      expect(decoded['id'], term1.id);
      expect(decoded['locked'], true);
    });

    test('updateTerm correctly updates term', () async {
      when(
        () => mockSharedPreferences.getStringList('searchTerms'),
      ).thenReturn(termsAsJsonStrings);

      when(
        () => mockSharedPreferences.setStringList(
          'searchTerms',
          any<List<String>>(),
        ),
      ).thenAnswer((_) async => true);

      final container = createContainer();
      final notifier = container.read(newTrackedTermsProvider.notifier);

      final changeTerm = term1.copyWith(term: "Kotlin");

      await notifier.updateTerm(changeTerm, term1.notificationId);

      final updated = await container.read(newTrackedTermsProvider.future);
      expect(updated.length, 2);
      final updatedTerm = updated.firstWhere((t) => t.id == term1.id);
      expect(updatedTerm.term, "Kotlin");
    });
  });
}
