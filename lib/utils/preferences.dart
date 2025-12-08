import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

const String _searchTermsKey = 'searchTerms';
const String _notificationKey = 'notificationTime';

Future<void> saveSearchTerms(List<String> terms) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(_searchTermsKey, terms);
}

Future<List<String>> loadSearchTerms() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList(_searchTermsKey) ?? [];
}

Future<void> saveNotificationTime(TimeOfDay notificationTime) async {
  final prefs = await SharedPreferences.getInstance();
  final timeString = '${notificationTime.hour}:${notificationTime.minute}';
  await prefs.setString(_notificationKey, timeString);
}

Future<TimeOfDay?> loadNotificationTime() async {
  final prefs = await SharedPreferences.getInstance();
  final timeString = prefs.getString(_notificationKey);
  if (timeString == null) return null;
  final parts = timeString.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}
