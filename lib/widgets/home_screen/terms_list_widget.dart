import 'package:flutter/material.dart';
import 'package:news_tracker/widgets/home_screen/term_tile_widget.dart';

import '../../model/tracked_term.dart';

class TermsList extends StatelessWidget {
  final List<TrackedTerm> terms;
  final Future<void> Function(TrackedTerm) onViewDetails;
  final Future<void> Function(TrackedTerm) onToggleLocked;
  final Future<void> Function(TrackedTerm) onDelete;
  final Future<void> Function(TrackedTerm, TimeOfDay) onSetTime;

  const TermsList({
    super.key,
    required this.terms,
    required this.onViewDetails,
    required this.onToggleLocked,
    required this.onDelete,
    required this.onSetTime,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: terms.isEmpty
              ? Text('Add search terms below')
              : SizedBox.shrink(),
        ),
        ...terms.map(
          (term) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: TermTile(
              term: term,
              onViewDetails: onViewDetails,
              onToggleLocked: onToggleLocked,
              onDelete: onDelete,
              onSetTime: onSetTime,
            ),
          ),
        ),
      ],
    );
  }
}
