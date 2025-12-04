import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/model/tracked_term.dart';
import 'package:news_tracker/utils/notifications/initialize_notifications.dart';
import 'package:news_tracker/utils/notifications/schedule_notification.dart';
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

  Future<List<TrackedTerm>> getAllTerms() async {
    final current = await loadSearchTerms();
    return deserializeTermListHelper(current);
  }

  /// Creates a TrackedTerm object with a UUID and a notification Id
  Future<void> add(String term, bool locked) async {
    print('Adding term');
    final uuid = Uuid();
    final id = uuid.v4();
    final time = await loadNotificationTime() ?? TimeOfDay.now();
    final termObj = TrackedTerm(
      term: term,
      notificationId: await getNextNotificationId(),
      id: id,
      locked: locked,
      notificationTime: time,
    );
    print(termObj.notificationTime);
    final jsonString = jsonEncode(termObj);
    final current = await loadSearchTerms();
    final terms = [...current, jsonString];
    for (var t in terms) {
      print(t);
    }
    state = AsyncValue.data(deserializeTermListHelper(terms));

    await scheduleNotificationFromTerm(termObj, notificationsPlugin);
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
    await Future.wait([
      cancelNotificationByTerm(term, null),
      releaseNotificationId(term.notificationId),
    ]);
  }

  Future<void> updateTerm(TrackedTerm term, int oldId) async {
    final current = await loadSearchTerms();
    final termObjects = deserializeTermListHelper(current);
    final updated = termObjects.map((t) {
      if (t.id == term.id) {
        return term;
      }
      return t;
    }).toList();

    state = AsyncValue.data(updated);

    final updatedStrings = serializeTermListHelper(updated);
    await saveSearchTerms(updatedStrings);
    await releaseNotificationId(oldId);
  }

  Future<void> updateMany(List<TrackedTerm> updatedTerms) async {
    final termStrings = await loadSearchTerms();
    final current = deserializeTermListHelper(termStrings);

    final currentById = {for (var t in current) t.id: t};
    final updatedById = {for (var t in updatedTerms) t.id: t};

    final merged = current
        .map((t) => updatedById.containsKey(t.id) ? updatedById[t.id]! : t)
        .toList();
    for (var t in updatedTerms) {
      if (!currentById.containsKey(t.id)) merged.add(t);
    }

    state = AsyncValue.data(merged);
    final updatedStrings = serializeTermListHelper(merged);
    await saveSearchTerms(updatedStrings);

    for (var newTerm in updatedTerms) {
      final old = currentById[newTerm.id];
      if (old == null) {
        await scheduleNotificationFromTerm(newTerm, notificationsPlugin);
        continue;
      }

      if (old.notificationId != newTerm.notificationId) {
        await cancelNotificationByTerm(old, null);
        await releaseNotificationId(old.notificationId);
        await scheduleNotificationFromTerm(newTerm, notificationsPlugin);
        continue;
      }

      if (old.notificationTime != newTerm.notificationTime ||
          old.locked != newTerm.locked ||
          old.term != newTerm.term) {
        await cancelNotificationByTerm(old, null);
        await scheduleNotificationFromTerm(newTerm, notificationsPlugin);
      }
    }
  }

  Future<void> toggleLocked(TrackedTerm term) async {
    final current = await loadSearchTerms();
    final termObjects = deserializeTermListHelper(current);
    final updated = termObjects.map((t) {
      if (t.id == term.id) {
        print(
          'Changing locked status of ${t.term} from ${t.locked} to ${!t.locked}',
        );
        return t.copyWith(locked: !t.locked);
      }
      return t;
    }).toList();

    state = AsyncValue.data(updated);

    final updatedStrings = serializeTermListHelper(updated.toList());
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

final newTrackedTermsProvider =
    AsyncNotifierProvider<TrackedTermNotifierLocked, List<TrackedTerm>>(
      TrackedTermNotifierLocked.new,
    );
