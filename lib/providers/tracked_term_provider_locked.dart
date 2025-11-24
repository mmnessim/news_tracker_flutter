import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/model/tracked_term.dart';
import 'package:news_tracker/utils/preferences.dart';
import 'package:uuid/uuid.dart';

class TrackedTermProviderLocked extends AsyncNotifier<List<TrackedTerm>> {
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

  Future<void> add(String term, bool locked) async {
    final uuid = Uuid();
    final id = uuid.v4();
    final termObj = TrackedTerm(term: term, id: id, locked: locked);
    final jsonString = jsonEncode(termObj);
    final current = await loadSearchTerms();
    final terms = [...current, jsonString];
    state = AsyncValue.data(deserializeTermListHelper(terms));
    await saveSearchTerms(terms);
  }

  Future<void> remove(String term, String? id) async {
    final current = await loadSearchTerms();
    final termObjs = deserializeTermListHelper(current);
    final updated = termObjs.where((t) => t.term != term).toList();
    state = AsyncValue.data(updated);
    final updatedStrings = serializeTermListHelper(updated);
    await saveSearchTerms(updatedStrings);
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
