import 'package:flutter/material.dart';

import '../../../model/tracked_term.dart';
import 'individual_time_picker_row_widget.dart';

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
              onPressed: () {
                if (term.locked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cannot delete locked term')),
                  );
                  return;
                }
                term.locked ? [] : onDelete(term);
              },
            ),
          ],
        ),
      ),
    );
  }
}
