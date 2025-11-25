import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:news_tracker/providers/notification_provider.dart';
import 'package:news_tracker/utils/notifications/pending_notifications.dart';

class NotificationDetails extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationAsync = ref.watch(notificationProvider);
    return Row(
      children: [
        notificationAsync.when(
          loading: () => CircularProgressIndicator(),
          error: (err, stack) => Text('Error: $err'),
          data: (notifications) {
            for (var n in notifications) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'ID: ${n.id}\nPayload: ${n.payload}\nTitle: ${n.title}',
                  ),
                ),
              );
            }

            if (notifications.isEmpty) {
              return Text('No notifications scheduled');
            } else {
              return SizedBox(width: 1);
            }
          },
        ),
      ],
    );
  }
}

class _NotificationDetails extends StatelessWidget {
  final int id;

  const _NotificationDetails({super.key, required this.id});

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

        if (pending.payload != null && pending.payload!.isNotEmpty) {
          try {
            final map = jsonDecode(pending.payload!);
            if (map is Map && map['scheduledAt'] is String) {
              scheduledText = _formatIso(map['scheduledAt']);
            }
          } catch (_) {
            scheduledText = 'Invalid payload data';
          }
        }
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
