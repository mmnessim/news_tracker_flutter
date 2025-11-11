import 'package:flutter/material.dart';

class PageBodyContainer extends StatelessWidget {
  final List<Widget> children;

  const PageBodyContainer({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ),
      ),
    );
  }
}
