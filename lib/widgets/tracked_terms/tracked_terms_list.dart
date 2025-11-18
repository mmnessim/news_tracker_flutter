import 'package:flutter/material.dart';
import 'package:news_tracker/details.dart';

import 'tracked_term_tile.dart';

class TrackedTermsList extends StatelessWidget {
  final List<String> terms;
  final Function(String) onButtonClicked;

  const TrackedTermsList({
    super.key,
    required this.terms,
    required this.onButtonClicked,
  });

  @override
  Widget build(BuildContext context) {
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
                removeSearchTerm: onButtonClicked,
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
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          ),
        ],
      );
    }
  }
}
