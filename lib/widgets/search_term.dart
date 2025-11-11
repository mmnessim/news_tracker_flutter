import 'package:flutter/material.dart';

class SearchTerm extends StatelessWidget {
  final String term;
  final void Function(String) onButtonClicked;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final void Function()? onTap;

  const SearchTerm({
    super.key,
    required this.term,
    required this.onButtonClicked,
    this.padding = const EdgeInsets.all(8.0),
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color:
              backgroundColor ??
              Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(Icons.article, size: 18, color: Colors.black),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      term,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  foregroundColor: Colors.black,
                ),
                onPressed: () => onButtonClicked(term),
                child: Text(
                  '-',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
