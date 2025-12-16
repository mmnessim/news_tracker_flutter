import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/presentation/screens/home/terms_list_widget.dart';
import 'package:news_tracker/presentation/shared_widgets/app_bar.dart';
import 'package:news_tracker/presentation/shared_widgets/drawer.dart';
import 'package:news_tracker/presentation/shared_widgets/page_body_container.dart';
import 'package:news_tracker/view_model/tracked_terms_list_view_model.dart';

import '../details/details_screen.dart';
import 'term_input_widget.dart';

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
          Expanded(
            child: TermsList(
              terms: terms ?? [],
              onViewDetails: (term) async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailsPage(term: term)),
                );
              },
              onDelete: (term) => notifier.removeTrackedTerm(term),
              onToggleLocked: (term) => notifier.toggleLocked(term),
              onSetTime: notifier.updateSingleNotificationTime,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 32, left: 8, right: 8),
            child: SafeArea(
              top: false,
              child: TermInput(
                onAdd: (term, flag) => notifier.addTrackedTerm(term, flag),
              ),
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
