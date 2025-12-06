import 'package:flutter/material.dart';

import '../../model/tracked_term.dart';

class TermTile extends StatelessWidget {
  final TrackedTerm term;
  final Future<void> Function(TrackedTerm) onViewDetails;
  final Future<void> Function(TrackedTerm) onToggleLocked;
  final Future<void> Function(TrackedTerm) onDelete;
  final Future<void> Function(TrackedTerm, TimeOfDay) onSetTime;

  const TermTile({
    super.key,
    required this.term,
    required this.onViewDetails,
    required this.onToggleLocked,
    required this.onDelete,
    required this.onSetTime,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onViewDetails(term),
      child: ListTile(
        title: Text(term.term),
        subtitle: Text(
          term.notificationTime != null
              ? term.notificationTime!.format(context)
              : '',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Set notification time for ${term.term}'),
                    content: IndividualTimePicker(
                      term: term,
                      onSetTime: onSetTime,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(term.locked ? Icons.lock : Icons.lock_open),
              onPressed: () => onToggleLocked(term),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline),
              onPressed: () => term.locked ? [] : onDelete(term),
            ),
          ],
        ),
      ),
    );
  }
}

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
