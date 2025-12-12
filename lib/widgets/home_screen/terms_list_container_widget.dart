import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/widgets/home_screen/terms_list_widget.dart';

import '../../model/tracked_term.dart';
import '../../screens/details_screen.dart';
import '../../view_model/tracked_terms_list_view_model.dart';

class TermsListContainer extends ConsumerWidget {
  final List<TrackedTerm> terms;

  const TermsListContainer({super.key, required this.terms});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final terms = ref.watch(
    //   homeScreenVMProvider.select(
    //     (state) => state.maybeWhen(
    //       data: (s) => s.terms,
    //       orElse: () => <TrackedTerm>[],
    //     ),
    //   ),
    // );
    final notifier = ref.read(homeScreenVMProvider.notifier);
    return TermsList(
      terms: [...terms],
      onViewDetails: (term) async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailsPage(term: term)),
        );
      },
      onDelete: (term) => notifier.removeTrackedTerm(term),
      onToggleLocked: (term) => notifier.toggleLocked(term),
      onSetTime: notifier.updateSingleNotificationTime,
    );
  }
}
