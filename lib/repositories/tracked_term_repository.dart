import 'dart:convert';

import 'package:news_tracker/model/tracked_term.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackedTermsRepository {
  static const String _key = 'tracked_terms';

  TrackedTermsRepository();

  Future<List<TrackedTerm>> fetchAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null || jsonString.isEmpty) return [];
    final List decoded = jsonDecode(jsonString) as List;
    return decoded
        .map((m) => TrackedTerm(term: m['term'] as String, id: m['id'] as int))
        .toList();
  }

  Future<void> add(TrackedTerm term) async {
    final items = await fetchAll();
    final newList = List<TrackedTerm>.from(items)..add(term);
    await _saveAll(newList);
  }

  Future<void> remove(int id) async {
    final items = await fetchAll();
    final newList = items.where((t) => t.id != id).toList();
    await _saveAll(newList);
  }

  Future<void> _saveAll(List<TrackedTerm> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      items.map((t) => <String, Object>{'term': t.term, 'id': t.id}).toList(),
    );
    await prefs.setString(_key, encoded);
  }
}
