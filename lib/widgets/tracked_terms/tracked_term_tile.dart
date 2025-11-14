import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:news_tracker/utils/notifications/pending_notifications.dart';
import 'package:intl/intl.dart';

class TrackedTermTile extends StatelessWidget {
  final String term;
  final void Function(String) onButtonClicked;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final void Function()? onTap;
  final int id;

  const TrackedTermTile({
    super.key,
    required this.term,
    required this.onButtonClicked,
    this.padding = const EdgeInsets.all(8.0),
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.onTap,
    required this.id,
  });

  String _formatIso(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat(' h:mm a').format(dt);
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color:
              backgroundColor ??
              Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(Icons.article, size: 18, color: Colors.black),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      term,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder(
              future: getNotificationById(id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('${snapshot.error}');
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

                return Row(
                  children: [
                    Icon(Icons.notifications, size: 18, color: Colors.black),
                    const SizedBox(width: 4),
                    Text(scheduledText),
                  ],
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  foregroundColor: Colors.black,
                ),
                onPressed: () => onButtonClicked(term),
                child: Text(
                  '-',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
