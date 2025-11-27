import 'package:flutter/material.dart';
import 'package:news_tracker/widgets/time_picker_row.dart';

class GlobalNotificationTimeWidget extends StatelessWidget {
  final TimeOfDay time;

  GlobalNotificationTimeWidget({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Set Notification Time'),
            content: TimePickerRow(),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications),
          SizedBox(width: 4.0),
          Text(time.format(context)),
        ],
      ),
    );
  }
}
