import 'package:flutter/material.dart';

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
        IconButton(
          onPressed: () {
            setState(() {
              _flag = !_flag;
            });
          },
          icon: Icon(_flag ? Icons.lock : Icons.lock_open),
        ),
        // Checkbox(
        //   value: _flag,
        //   onChanged: (v) => setState(() => _flag = v ?? false),
        // ),
        ElevatedButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}
