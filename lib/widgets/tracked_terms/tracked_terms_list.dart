import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/details.dart';
import 'package:news_tracker/providers/tracked_term_provider.dart';

import 'tracked_term_tile.dart';

class TrackedTermsList extends ConsumerWidget {
  const TrackedTermsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final termsAsync = ref.watch(trackedTermsProvider);

    return termsAsync.when(
      data: (terms) {
        if (terms.isEmpty) {
          return ListView(
            shrinkWrap: true,
            children: [ListTile(title: Text('Add search terms below'))],
          );
        } else {
          return ListView(
            shrinkWrap: true,
            children: [
              ...terms.map(
                (term) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: TrackedTermTile(
                    term: term,
                    id: terms.indexOf(term),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 24.0,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsPage(term: term),
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
