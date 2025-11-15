import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:news_tracker/utils/notifications/pending_notifications.dart';
import 'package:intl/intl.dart';

class TrackedTermTile extends StatefulWidget {
  final String term;
  final void Function(String) removeSearchTerm;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final void Function()? onTap;
  final int id;
  final int refreshId;

  const TrackedTermTile({
    super.key,
    required this.term,
    required this.removeSearchTerm,
    this.padding = const EdgeInsets.all(8.0),
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.onTap,
    required this.id,
    required this.refreshId,
  });

  @override
  State<TrackedTermTile> createState() => _TrackedTermTileState();
}

class _TrackedTermTileState extends State<TrackedTermTile> {
  String scheduledText = '';

  String _formatIso(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat(' h:mm a').format(dt);
    } catch (_) {
      return iso;
    }
  }

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    final pending = await getNotificationById(widget.id);
    if (pending != null &&
        pending.payload != null &&
        pending.payload!.isNotEmpty) {
      try {
        final map = jsonDecode(pending.payload!);
        if (map is Map && map['scheduledAt'] is String) {
          setState(() {
            scheduledText = _formatIso(map['scheduledAt']);
          });
        }
      } catch (_) {
        setState(() {
          scheduledText = 'Invalid payload data';
        });
      }
    } else {
      setState(() {
        scheduledText = 'No notifications pending';
      });
    }
  }

  @override
  void didUpdateWidget(covariant TrackedTermTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshId != widget.refreshId) {
      _initAsync();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onLongPress: () async {
        showDialog(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Confirm'),
              content: const Text('Delete this term?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  // closes dialog
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // close first
                    widget.removeSearchTerm(widget.term); // then perform action
                  },
                  child: const Text('Delete term'),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        width: double.infinity,
        padding: widget.padding,
        decoration: BoxDecoration(
          color:
              widget.backgroundColor ??
              Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(widget.borderRadius),
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
                      widget.term,
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
            Row(
              children: [
                Icon(Icons.notifications, size: 18, color: Colors.black),
                const SizedBox(width: 4),
                Text(scheduledText),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
