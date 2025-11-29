import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/model/tracked_term.dart';
import 'package:news_tracker/providers/notification_time_provider.dart';
import 'package:news_tracker/providers/tracked_term_provider_locked.dart';

// TODO: Notification time just shows the global notification time, not each individual term's notification time
class TrackedTermTile extends ConsumerWidget {
  final TrackedTerm termObject;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final void Function()? onTap;

  TrackedTermTile({
    super.key,
    required this.termObject,
    this.padding = const EdgeInsets.all(8.0),
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.onTap,
  });

  // String _formatIso(String iso) {
  //   try {
  //     final dt = DateTime.parse(iso).toLocal();
  //     return DateFormat(' h:mm a').format(dt);
  //   } catch (_) {
  //     return iso;
  //   }
  // }

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
              title: Text('Manage "${termObject.term}"'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    ref
                        .read(newTrackedTermsProvider.notifier)
                        .remove(termObject);
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
                      termObject.term,
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
                    Text('${termObject.notificationTime?.format(context)}'),
                    IconButton(
                      onPressed: () async {
                        await ref
                            .read(newTrackedTermsProvider.notifier)
                            .toggleLocked(termObject);
                      },
                      icon: Icon(
                        termObject.locked ? Icons.lock : Icons.lock_open,
                        size: 18,
                        color: Colors.black,
                      ),
                    ),
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
