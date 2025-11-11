import 'package:flutter/material.dart';
import 'package:news_tracker/details.dart';

import 'search_term.dart';

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
              child: SearchTerm(
                term: term,
                onButtonClicked: onButtonClicked,
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
