import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/view_model/tracked_terms_view_model.dart';
import 'package:news_tracker/views/details.dart';
import 'package:news_tracker/providers/tracked_term_provider.dart';

import '../../model/tracked_term.dart';
import 'tracked_term_tile.dart';

class BTrackedTermsList extends ConsumerStatefulWidget {
  const BTrackedTermsList({super.key});

  @override
  ConsumerState<BTrackedTermsList> createState() => BTrackedTermsListState();
}

class BTrackedTermsListState extends ConsumerState<BTrackedTermsList> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTerm() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final newTerm = TrackedTerm(
      id: DateTime.now().millisecondsSinceEpoch,
      term: text,
    );

    ref.read(trackedTermsViewModelProvider.notifier).add(newTerm);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final termsAsync = ref.watch(trackedTermsViewModelProvider);
    final vm = ref.read(trackedTermsViewModelProvider.notifier);

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: termsAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const Center(child: Text('No tracked terms'));
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final t = items[index];
                      // return TrackedTermTile(term: t.term, id: t.id);
                      return ListTile(
                        title: Text(t.term),
                        subtitle: Text('id: ${t.id}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => vm.remove(t.id),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Add tracked term',
                    ),
                    onSubmitted: (_) => _addTerm(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addTerm, child: const Text('Add')),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class TrackedTermsList extends ConsumerWidget {
  const TrackedTermsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final termsAsync = ref.watch(trackedTermsProvider);

    return termsAsync.when(
      data: (terms) {
        if (terms.isEmpty) {
          return ListView(
            shrinkWrap: true,
            children: [ListTile(title: Text('Add search terms below'))],
          );
        } else {
          return ListView(
            shrinkWrap: true,
            children: [
              ...terms.map(
                (term) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: TrackedTermTile(
                    term: term,
                    id: terms.indexOf(term),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 24.0,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsPage(term: term),
                        ),
                      );
                    },
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                  ),
                ),
              ),
            ],
          );
        }
      },
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error $err'),
    );
  }
}
