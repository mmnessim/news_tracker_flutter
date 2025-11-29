import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/view_model/tracked_terms_list_view_model.dart';
import 'package:news_tracker/widgets/coreui/app_bar.dart';
import 'package:news_tracker/widgets/coreui/drawer.dart';
import 'package:news_tracker/widgets/page_body_container.dart';

import '../details.dart';
import '../model/tracked_term.dart';
import '../new_widgets/term_inputs_widget.dart';
import '../new_widgets/terms_list_widget.dart';

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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('Length: ${terms.length}'),
          TermsList(
            terms: [...terms],
            onViewDetails: (term) async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsPage(term: term),
                ),
              );
            },
            onToggleLocked: (term) =>
                ref.read(homeScreenVMProvider.notifier).toggleLocked(term),
            onDelete: (term) =>
                ref.read(homeScreenVMProvider.notifier).removeTrackedTerm(term),
          ),
          Spacer(),
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
