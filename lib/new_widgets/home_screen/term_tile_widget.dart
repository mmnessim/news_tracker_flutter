import 'package:flutter/material.dart';

import '../../model/tracked_term.dart';

class TermTile extends StatelessWidget {
  final TrackedTerm term;
  final Future<void> Function(TrackedTerm) onViewDetails;
  final Future<void> Function(TrackedTerm) onToggleLocked;
  final Future<void> Function(TrackedTerm) onDelete;

  const TermTile({
    super.key,
    required this.term,
    required this.onViewDetails,
    required this.onToggleLocked,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
            onPressed: () => onViewDetails(term),
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
    );
  }
}
