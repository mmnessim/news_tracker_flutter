import 'package:flutter/material.dart';

import '../../../model/tracked_term.dart';

class IndividualTimePicker extends StatelessWidget {
  final TrackedTerm term;
  final Future<void> Function(TrackedTerm, TimeOfDay) onSetTime;

  const IndividualTimePicker({
    super.key,
    required this.term,
    required this.onSetTime,
  });

  Future<void> _setNotificationTime(
    BuildContext context,
    TimeOfDay currentTime,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );
    if (picked == null) return;
    await onSetTime(term, picked);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    var time = term.notificationTime;

    return Container(
      color: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: InkWell(
        onTap: () {
          _setNotificationTime(
            context,
            term.notificationTime ?? TimeOfDay.now(),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Notification time: ${time?.format(context)}',
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
  }
}
