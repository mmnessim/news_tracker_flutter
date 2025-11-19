import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/providers/tracked_term_provider.dart';

class AddTrackedTerm extends ConsumerWidget {
  final TextEditingController _controller = TextEditingController();

  String? handleInput() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      _controller.clear();
      return text;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> addSearchTerm(String term) async {
      await ref.read(trackedTermsProvider.notifier).add(term);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
              onPressed: () {
                final term = handleInput();
                if (term != null) {
                  addSearchTerm(term);
                }
              },
              child: const Text("Track New Term"),
            ),
          ],
        ),
      ],
    );
  }
}

//
// class AddTrackedTerm extends StatefulWidget {
//   final void Function(String) onSearchTermAdded;
//
//   const AddTrackedTerm({super.key, required this.onSearchTermAdded});
//
//   @override
//   State<AddTrackedTerm> createState() => _AddTrackedTermState();
// }
//
// class _AddTrackedTermState extends State<AddTrackedTerm> {
//   final TextEditingController _controller = TextEditingController();
//
//   void _addSearchTerm() {
//     final text = _controller.text.trim();
//     if (text.isNotEmpty) {
//       widget.onSearchTermAdded(text);
//       _controller.clear();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Text("Enter Search Terms"),
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
//           child: TextField(
//             controller: _controller,
//             decoration: const InputDecoration(
//               labelText: "Terms to Track",
//               border: OutlineInputBorder(),
//             ),
//           ),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: _addSearchTerm,
//               child: const Text("Track New Term"),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
