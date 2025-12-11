import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:news_tracker/providers/notification_provider.dart';

import '../../utils/notifications/notification_helpers.dart';

class NotificationDetailsWidget extends ConsumerStatefulWidget {
  const NotificationDetailsWidget({super.key});

  @override
  ConsumerState<NotificationDetailsWidget> createState() =>
      _NotificationDetailsState();
}

class _NotificationDetailsState
    extends ConsumerState<NotificationDetailsWidget> {
  bool _listenerRegistered = false;

  @override
  Widget build(BuildContext context) {
    if (!_listenerRegistered) {
      ref.listen(notificationProvider, (_, __) {
        if (mounted) setState(() {});
      });
      _listenerRegistered = true;
    }

    final notificationAsync = ref.watch(notificationProvider);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(notificationProvider);
              },
            ),
          ],
        ),
        Expanded(
          child: notificationAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (notifications) {
              if (notifications.isEmpty) {
                return const Center(child: Text('No notifications scheduled'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(8.0),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final n = notifications[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Text(
                      'ID: ${n.id}\nPayload: ${n.payload}\nTitle: ${n.title}\n',
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

@Deprecated('Use NotificationDetails instead')
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
