import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/providers/notification_time_provider.dart';

class TimePickerRow extends ConsumerWidget {
  final Future<void> Function(TimeOfDay)? onSetTime;

  TimePickerRow({super.key, this.onSetTime});

  void _setNotificationTime(
    BuildContext context,
    TimeOfDay currentTime,
    WidgetRef ref,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );
    if (picked == null) return;

    if (onSetTime != null) {
      onSetTime!(picked);
      // ref.read(notificationTimeProvider.notifier).setNewTime(picked);
      return;
    }
    // rescheduleAllNotifications(ref, null);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeAsync = ref.watch(notificationTimeProvider);
    return timeAsync.when(
      data: (time) {
        if (time == null) {
          _setNotificationTime(context, TimeOfDay.now(), ref);
        }
        return Container(
          color: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: InkWell(
            onTap: () {
              _setNotificationTime(context, time, ref);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Notification time: ${time!.format(context)}',
                    style: TextStyle(color: Colors.white),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
                Icon(Icons.access_time_outlined, color: Colors.white),
              ],
            ),
          ),
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error $err'),
    );
  }
}
