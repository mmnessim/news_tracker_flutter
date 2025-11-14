import 'package:flutter/material.dart';

class AddTrackedTerm extends StatefulWidget {
  final void Function(String) onSearchTermAdded;

  const AddTrackedTerm({super.key, required this.onSearchTermAdded});

  @override
  State<AddTrackedTerm> createState() => _AddTrackedTermState();
}

class _AddTrackedTermState extends State<AddTrackedTerm> {
  final TextEditingController _controller = TextEditingController();

  void _addSearchTerm() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSearchTermAdded(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // Center horizontally
      children: [
        const Text("Enter Search Terms"),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: "Terms to Track",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _addSearchTerm,
              child: const Text("Track New Term"),
            ),
          ],
        ),
      ],
    );
  }
}
