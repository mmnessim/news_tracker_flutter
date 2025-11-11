import 'package:flutter/material.dart';

class NewsFetcher extends StatelessWidget {
  final String term;
  final void Function(String) onButtonClicked;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final bool isActive;

  const NewsFetcher({
    super.key,
    required this.term,
    required this.onButtonClicked,
    this.padding = const EdgeInsets.all(8.0),
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.secondaryContainer
            : Colors.transparent,
        border: isActive
            ? Border.all(
                color: Theme.of(context).colorScheme.secondary,
                width: 2,
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(term)),
          ElevatedButton(
            onPressed: () {
              onButtonClicked(term);
            },
            child: Text("See News Now"),
          ),
        ],
      ),
    );
  }
}
