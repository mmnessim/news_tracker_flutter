import 'package:flutter/material.dart';

import '../time_picker_row.dart';

class DefaultBar extends StatelessWidget implements PreferredSizeWidget {
  const DefaultBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text('News Tracker'),
      actions: [
        IconButton(
          icon: Icon(Icons.access_time),
          tooltip: 'Set Notification Time',
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Set Notification Time'),
                content: TimePickerRow(),
              ),
            );
          },
        ),
      ],
    );
  }
}
