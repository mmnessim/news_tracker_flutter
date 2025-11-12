import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_tracker/utils/pending_notifications.dart';

class NotificationDetails extends StatelessWidget {
  final int id;

  const NotificationDetails({super.key, required this.id});

  String _formatIso(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('MMMM d, yyyy h:mm a').format(dt);
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getNotificationById(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final pending = snapshot.data;
        if (pending == null) {
          return const Center(child: Text('No notifications pending'));
        }

        String scheduledText = 'Unknown';
        String payloadData = '';

        if (pending.payload != null && pending.payload!.isNotEmpty) {
          try {
            final map = jsonDecode(pending.payload!);
            if (map is Map && map['scheduledAt'] is String) {
              scheduledText = _formatIso(map['scheduledAt']);
            }
            if (map is Map && map['data'] != null) {
              payloadData = map['data'].toString();
            }
          } catch (_) {
            // ignore JSON parse errors
            payloadData = pending.payload!;
          }
        }
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ID: ${pending.id}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text('Title: ${pending.title ?? ''}'),
              const SizedBox(height: 8),
              Text('Body: ${pending.body ?? ''}'),
              const SizedBox(height: 8),
              Text('Payload: $payloadData'),
              const SizedBox(height: 12),
              Text(
                'Scheduled for: $scheduledText',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}
