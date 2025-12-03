import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/view_model/tracked_terms_list_view_model.dart';
import 'package:news_tracker/widgets/coreui/app_bar.dart';
import 'package:news_tracker/widgets/coreui/drawer.dart';
import 'package:news_tracker/widgets/page_body_container.dart';

import '../new_widgets/home_screen/term_inputs_widget.dart';
import '../new_widgets/home_screen/terms_list_container_widget.dart';

class HomeScreen extends ConsumerWidget {
  final bool showPermissionDialog;

  HomeScreen({super.key, required this.showPermissionDialog});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (showPermissionDialog) {
      permissionCallback(context);
    }

    final vm = ref.watch(homeScreenVMProvider);
    final notifier = ref.read(homeScreenVMProvider.notifier);
    final terms = vm.value?.terms;

    return Scaffold(
      appBar: DefaultBar(onSetTime: notifier.updateGlobalNotificationTime),
      drawer: OptionsDrawer(),
      body: PageBodyContainer(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Text('Length: ${terms.length}'),
          TermsListContainer(terms: terms ?? []),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 32, left: 8, right: 8),
            child: TermInput(
              onAdd: (term, flag) => notifier.addTrackedTerm(term, flag),
            ),
          ),
        ],
      ),
    );
  }

  void permissionCallback(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Notification Permission'),
          content: Text(
            'Notification permission is permanently denied. NewsTracker will not '
            'work properly without notification permission. Visit your phone\'s '
            'Settings -> Apps -> NewsTracker -> Permissions to enable',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    });
  }
}
