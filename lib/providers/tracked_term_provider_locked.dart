import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/model/tracked_term.dart';
import 'package:news_tracker/utils/preferences.dart';
import 'package:uuid/uuid.dart';

import '../utils/notifications/notification_id.dart';

class TrackedTermNotifierLocked extends AsyncNotifier<List<TrackedTerm>> {
  // TODO: There's probably a better way to do this. Maybe loadSearchTerms()
  // directly serializes/deserializes
  @override
  FutureOr<List<TrackedTerm>> build() async {
    final current = await loadSearchTerms();
    List<TrackedTerm> terms = [];
    for (var t in current) {
      try {
        final decoded = jsonDecode(t);
        final trackedTerm = TrackedTerm.fromJson(decoded);
        terms.add(trackedTerm);
      } catch (e) {
        print('Error: $e');
        continue;
      }
    }
    return terms;
  }

  /// Creates a TrackedTerm object with a UUID and a notification Id
  Future<void> add(String term, bool locked) async {
    print('Adding term');
    final uuid = Uuid();
    final id = uuid.v4();
    final termObj = TrackedTerm(
      term: term,
      notificationId: await getNextNotificationId(),
      id: id,
      locked: locked,
    );
    final jsonString = jsonEncode(termObj);
    final current = await loadSearchTerms();
    final terms = [...current, jsonString];
    for (var t in terms) {
      print(t);
    }
    state = AsyncValue.data(deserializeTermListHelper(terms));
    await saveSearchTerms(terms);
  }

  @Deprecated('Use remove(TrackedTerm term) instead')
  Future<void> removeTermByString(String term, String? id) async {
    final current = await loadSearchTerms();
    final termObjects = deserializeTermListHelper(current);
    final updated = termObjects.where((t) => t.id != id).toList();
    state = AsyncValue.data(updated);
    final updatedStrings = serializeTermListHelper(updated);
    await saveSearchTerms(updatedStrings);
  }

  Future<void> remove(TrackedTerm term) async {
    final current = await loadSearchTerms();
    final termObjects = deserializeTermListHelper(current);
    final updated = termObjects.where((t) => t.id != term.id).toList();
    state = AsyncValue.data(updated);
    final updatedStrings = serializeTermListHelper(updated);
    await saveSearchTerms(updatedStrings);
    await releaseNotificationId(term.notificationId);
  }

  /// Helper function to update state when terms are added or removed
  List<TrackedTerm> deserializeTermListHelper(List<String> termStrings) {
    List<TrackedTerm> terms = [];
    for (String term in termStrings) {
      try {
        final decoded = jsonDecode(term);
        final termObj = TrackedTerm.fromJson(decoded);
        terms.add(termObj);
      } catch (e) {
        continue;
      }
    }
    return terms;
  }

  List<String> serializeTermListHelper(List<TrackedTerm> termObjects) {
    List<String> termStrings = [];
    for (TrackedTerm term in termObjects) {
      try {
        final encoded = jsonEncode(term);
        termStrings.add(encoded);
      } catch (e) {
        continue;
      }
    }
    return termStrings;
  }
}

final newTrackedTermsProvider =
    AsyncNotifierProvider<TrackedTermNotifierLocked, List<TrackedTerm>>(
      TrackedTermNotifierLocked.new,
    );
