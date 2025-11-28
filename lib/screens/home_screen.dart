import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_tracker/view_model/tracked_terms_list_view_model.dart';
import 'package:news_tracker/widgets/coreui/app_bar.dart';
import 'package:news_tracker/widgets/coreui/drawer.dart';
import 'package:news_tracker/widgets/page_body_container.dart';

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(trackedTermsListViewModelProvider);

    final add = ref
        .read(trackedTermsListViewModelProvider.notifier)
        .addTrackedTerm;

    final terms = vm.when(
      data: (state) => state.terms,
      loading: () => [],
      error: (_, _) => [],
    );

    return Scaffold(
      appBar: DefaultBar(),
      drawer: OptionsDrawer(),
      body: PageBodyContainer(
        children: [
          Text('Length: ${terms.length}'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
            child: TermInput(
              onAdd: (term, flag) => ref
                  .read(trackedTermsListViewModelProvider.notifier)
                  .addTrackedTerm(term, flag),
            ),
          ),
        ],
      ),
    );
  }
}

class TermInput extends StatefulWidget {
  final Future<void> Function(String, bool) onAdd;

  TermInput({super.key, required this.onAdd});

  @override
  State<TermInput> createState() => _TermInputState();
}

class _TermInputState extends State<TermInput> {
  final TextEditingController _controller = TextEditingController();
  bool _flag = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final term = _controller.text.trim();
    if (term.isEmpty) return;
    await widget.onAdd(term, _flag);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'Enter Search Terms'),
            onSubmitted: (_) => _submit(),
          ),
        ),
        Icon(_flag ? Icons.lock : Icons.lock_open),
        Checkbox(
          value: _flag,
          onChanged: (v) => setState(() => _flag = v ?? false),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}
