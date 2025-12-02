import 'package:flutter/material.dart';
import 'package:news_tracker/main.dart';

class PageBodyContainer extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;

  const PageBodyContainer({
    super.key,
    required this.children,
    required this.mainAxisAlignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Column(mainAxisAlignment: mainAxisAlignment, children: children),
      ),
    );
  }
}
