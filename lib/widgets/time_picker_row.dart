import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/providers/notification_time_provider.dart';
import 'package:news_tracker/utils/notifications/schedule_notification.dart';

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
    if (onSetTime != null && picked != null) {
      onSetTime!(picked);
      return;
    }
    if (picked != null) {
      ref.read(notificationTimeProvider.notifier).setNewTime(picked);
    }
    rescheduleAllNotifications(ref, null);
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
