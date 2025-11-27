import 'package:shared_preferences/shared_preferences.dart';

const String _kLastNotificationIdKey = 'last_notification_id';
const String _kActiveNotificationIdsKey = 'active_notification_ids';
const int _kMaxNotificationIds = (1 << 31) - 1; // Max 32 bit value
const int _kFirstNotificationId = 1;

Future<int> getNextNotificationId() async {
  final prefs = await SharedPreferences.getInstance();
  var last = prefs.getInt(_kLastNotificationIdKey) ?? 0;
  final activeList =
      prefs.getStringList(_kActiveNotificationIdsKey) ?? <String>[];
  final active = activeList.map(int.parse).toSet();

  for (int attempt = 0; attempt <= _kMaxNotificationIds; attempt++) {
    // Loop back to 1 if max number reached
    last = (last >= _kMaxNotificationIds) ? _kFirstNotificationId : last + 1;
    if (!active.contains(last)) {
      active.add(last);
      await prefs.setStringList(
        _kActiveNotificationIdsKey,
        active.map((e) => e.toString()).toList(),
      );
      await prefs.setInt(_kLastNotificationIdKey, last);
      return last;
    }
  }

  // If all IDs are in use
  throw Exception(
    'No available notification IDs. All IDs are currently in use',
  );
}

Future<void> releaseNotificationId(int id) async {
  final prefs = await SharedPreferences.getInstance();
  final list = prefs.getStringList(_kActiveNotificationIdsKey) ?? <String>[];
  final changed = list.remove(id.toString());
  if (changed) {
    await prefs.setStringList(_kActiveNotificationIdsKey, list);
  }
}
