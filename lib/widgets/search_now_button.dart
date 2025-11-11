import 'package:flutter/material.dart';
import 'package:news_tracker/about.dart';

class SearchNowButton extends StatelessWidget {
  const SearchNowButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AboutPage()),
        );
      },
      child: const Text('Search Now'),
    );
  }
}
