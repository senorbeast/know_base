import 'package:flutter/material.dart';

class TextBlockEditor extends StatefulWidget {
  final String initialText;
  final Function(String) onChanged;

  const TextBlockEditor({
    super.key,
    required this.initialText,
    required this.onChanged,
  });

  @override
  State<TextBlockEditor> createState() => _TextBlockEditorState();
}

class _TextBlockEditorState extends State<TextBlockEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      maxLines: null,
      decoration: const InputDecoration(
        hintText: 'Enter text...',
        border: InputBorder.none,
      ),
      onChanged: widget.onChanged,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
