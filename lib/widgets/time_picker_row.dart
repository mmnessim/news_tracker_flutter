import 'package:flutter/material.dart';
import 'package:news_tracker/utils/preferences.dart';
import 'package:news_tracker/utils/show_notification.dart';

class TimePickerRow extends StatefulWidget {
  const TimePickerRow({super.key, this.notificationTime});

  final TimeOfDay? notificationTime;

  @override
  State<TimePickerRow> createState() => _TimePickerRowState();
}

class _TimePickerRowState extends State<TimePickerRow> {
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _loadInitialTime();
  }

  Future<void> _loadInitialTime() async {
    final loadedTime = await loadNotificationTime();
    setState(() {
      _selectedTime = loadedTime ?? TimeOfDay.now();
    });
  }

  void _setNotificationTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
      await saveNotificationTime(picked);
    }
    showNotification('New Articles', 'Click here');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Notification time: ${_selectedTime.format(context)}',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: _setNotificationTime,
            child: Text('Select Notification Time'),
          ),
        ],
      ),
    );
  }
}
