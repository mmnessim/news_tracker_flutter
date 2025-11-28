import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/view_model/tracked_terms_list_view_model.dart';
import 'package:news_tracker/widgets/coreui/app_bar.dart';
import 'package:news_tracker/widgets/coreui/drawer.dart';
import 'package:news_tracker/widgets/page_body_container.dart';

import '../model/tracked_term.dart';
import '../new_widgets/term_inputs_widget.dart';

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(homeScreenVMProvider);

    final terms = vm.when(
      data: (state) => state.terms,
      loading: () => [],
      error: (_, _) => [],
    );

    return Scaffold(
      appBar: DefaultBar(),
      drawer: OptionsDrawer(),
      body: PageBodyContainer(
        children: [
          Text('Length: ${terms.length}'),
          TermsList(
            terms: [...terms],
            onViewDetails: (_) async {},
            onToggleLocked: (term) =>
                ref.read(homeScreenVMProvider.notifier).toggleLocked(term),
            onDelete: (term) =>
                ref.read(homeScreenVMProvider.notifier).removeTrackedTerm(term),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 32, left: 8, right: 8),
            child: TermInput(
              onAdd: (term, flag) => ref
                  .read(homeScreenVMProvider.notifier)
                  .addTrackedTerm(term, flag),
            ),
          ),
        ],
      ),
    );
  }
}

class TermsList extends StatelessWidget {
  final List<TrackedTerm> terms;
  final Future<void> Function(TrackedTerm) onViewDetails;
  final Future<void> Function(TrackedTerm) onToggleLocked;
  final Future<void> Function(TrackedTerm) onDelete;

  const TermsList({
    super.key,
    required this.terms,
    required this.onViewDetails,
    required this.onToggleLocked,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        terms.isEmpty ? Text('Add search terms below') : SizedBox.shrink(),
        ...terms.map(
          (term) =>
              Text('${term.term}: ${term.locked ? 'Locked' : 'Unlocked'}'),
        ),
      ],
    );
  }
}
