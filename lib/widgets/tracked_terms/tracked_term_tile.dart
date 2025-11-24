import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:news_tracker/providers/notification_time_provider.dart';
import 'package:news_tracker/providers/tracked_term_provider.dart';

class TrackedTermTile extends ConsumerWidget {
  final String term;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final void Function()? onTap;
  final String id;

  const TrackedTermTile({
    super.key,
    required this.term,
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
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationAsync = ref.watch(notificationTimeProvider);
    return InkWell(
      onTap: onTap,
      onLongPress: () async {
        showDialog(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text('Manage "$term"'),
              //content: const Text('Delete this term?'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    ref.read(trackedTermsProvider.notifier).remove(term);
                  },
                  child: const Text('Delete term'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
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

            notificationAsync.when(
              error: (err, stack) => Text("Error: $err"),
              loading: () => CircularProgressIndicator(),
              data: (time) {
                return Row(
                  children: [
                    Icon(Icons.notifications, size: 18, color: Colors.black),
                    const SizedBox(width: 4),
                    Text("${time?.format(context)}"),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
