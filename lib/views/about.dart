import 'package:flutter/material.dart';
import 'package:news_tracker/utils/preferences.dart';
import 'package:news_tracker/widgets/time_picker_row.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final List<String> _searchTerms = [];

  @override
  void initState() {
    super.initState();
    loadSearchTerms().then(
      (terms) => setState(() {
        _searchTerms.addAll(terms);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('About'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
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
            const Spacer(),
            InkWell(
              onTap: () async {
                await launchUrl(
                  Uri.parse(
                    'https://github.com/mmnessim/news_tracker_flutter.git',
                  ),
                );
              },
              child: Image.asset('assets/icon/github-mark.png', height: 32),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
