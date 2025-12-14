import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/presentation/shared_widgets/notification_widgets/notification_details.dart';
import 'package:news_tracker/presentation/shared_widgets/time_picker_row.dart';
import 'package:news_tracker/providers/tracked_term_provider_locked.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(newTrackedTermsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('About'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            TimePickerRow(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'News Tracker\n\n'
                'Version 0.0.1\n\n'
                'This app allows you to track specific search terms and receive daily notifications.'
                'You can add or remove search terms, and view detailed articles for each term.\n\n'
                'Written by Mounir Nessim.\n\n',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: NotificationDetailsWidget()),
            const SizedBox(height: 16),
            Center(
              child: InkWell(
                onTap: () async {
                  await launchUrl(
                    Uri.parse(
                      'https://github.com/mmnessim/news_tracker_flutter.git',
                    ),
                  );
                },
                child: Image.asset('assets/icon/github-mark.png', height: 32),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
