import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/details.dart';
import 'package:news_tracker/providers/notification_time_provider.dart';
import 'package:news_tracker/providers/tracked_term_provider_locked.dart';
import 'package:news_tracker/view_model/tracked_terms_list_view_model.dart';
import 'package:news_tracker/widgets/notification_widgets/global_notification_time_widget.dart';

import 'tracked_term_tile.dart';

class TrackedTermsList extends ConsumerStatefulWidget {
  const TrackedTermsList({super.key});

  @override
  ConsumerState<TrackedTermsList> createState() => _TrackedTermsListState();
}

class _TrackedTermsListState extends ConsumerState<TrackedTermsList> {
  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(trackedTermsListViewModelProvider);
    return vm.when(
      data: (state) {
        final terms = state.terms;
        final time = ref.watch(notificationTimeProvider).asData?.value;

        if (terms.isEmpty) {
          return ListView(
            shrinkWrap: true,
            children: [
              if (time != null)
                GlobalNotificationTimeWidget(time: time),
              const ListTile(title: Text('Add search terms below')),
            ],
          );
        } else {
          return ListView(
            shrinkWrap: true,
            children: [
              if (time != null)
                GlobalNotificationTimeWidget(time: time),
              ...terms.map(
                (term) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: TrackedTermTile(
                    termObject: term,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 24.0,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsPage(term: term.term),
                        ),
                      );
                    },
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  ),
                ),
              ),
            ],
          );
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error $err')),
    );
  }
}

class OldTrackedTermsList extends ConsumerWidget {
  const OldTrackedTermsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final termsAsync = ref.watch(newTrackedTermsProvider);
    final timeAsync = ref.watch(notificationTimeProvider);
    final time = timeAsync.when(
      loading: () => TimeOfDay.now(),
      error: (err, stack) => null,
      data: (t) => t,
    );

    return termsAsync.when(
      data: (terms) {
        if (terms.isEmpty) {
          return ListView(
            shrinkWrap: true,
            children: [
              (time != null)
                  ? GlobalNotificationTimeWidget(time: time)
                  : const SizedBox.shrink(),
              ListTile(title: Text('Add search terms below')),
            ],
          );
        } else {
          return ListView(
            shrinkWrap: true,
            children: [
              (time != null)
                  ? GlobalNotificationTimeWidget(time: time)
                  : const SizedBox.shrink(),
              ...terms.map(
                (term) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: TrackedTermTile(
                    termObject: term,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 24.0,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsPage(term: term.term),
                        ),
                      );
                    },
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                  ),
                ),
              ),
            ],
          );
        }
      },
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error $err'),
    );
  }
}
