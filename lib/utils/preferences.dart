import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

Future<void> saveSearchTerms(List<String> terms) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('searchTerms', terms);
}

Future<List<String>> loadSearchTerms() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('searchTerms') ?? [];
}

Future<void> saveNotificationTime(TimeOfDay notificationTime) async {
  final prefs = await SharedPreferences.getInstance();
  final timeString = '${notificationTime.hour}:${notificationTime.minute}';
  await prefs.setString('notificationTime', timeString);
}

Future<TimeOfDay?> loadNotificationTime() async {
  final prefs = await SharedPreferences.getInstance();
  final timeString = prefs.getString('notificationTime');
  if (timeString == null) return null;
  final parts = timeString.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}
