import 'dart:math';

import 'package:flutter/material.dart';
import 'package:news_tracker/widgets/shared/app_bar.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final PageController _controller = PageController();
  int _current = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'NewsTracker',
      'body': 'Keep up to date on topics you care about',
      'icon': Icons.newspaper,
    },
    {
      'title': 'Create',
      'body': 'Enter a term and press "Add"',
      'icon': Icons.add,
    },
    {
      'title': 'Schedule',
      'body': 'Set custom notification times for each term, or one global time',
      'icon': Icons.notifications_active,
    },
    {
      'title': 'Lock',
      'body': 'Lock terms to prevent accidental changes',
      'icon': Icons.lock,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    final page = _controller.hasClients && _controller.page != null
        ? _controller.page!.round()
        : _controller.initialPage;

    if (page != _current) {
      setState(() {
        _current = page;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultBar(),
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              scrollDirection: Axis.vertical,
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final data = _pages[index];
                double page = 0;
                if (_controller.hasClients && _controller.page != null) {
                  page = _controller.page!;
                }
                final diff = (page - index).abs();
                final scale = max(0.88, 1 - diff * 0.12);
                final opacity = max(0.6, 1 - diff * 0.6);

                return Center(
                  child: Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: StepCard(
                        title: data['title'] as String,
                        body: data['body'] as String,
                        icon: data['icon'] as IconData,
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              right: 12,
              top: 24,
              bottom: 24,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final active = i == _current;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    width: active ? 8 : 6,
                    height: active ? 24 : 10,
                    decoration: BoxDecoration(
                      color: active
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StepCard extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;

  const StepCard({
    super.key,
    required this.title,
    required this.body,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
