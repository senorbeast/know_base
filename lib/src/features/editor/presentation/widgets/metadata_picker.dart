import 'package:flutter/material.dart';

class MetadataPicker extends StatelessWidget {
  final List<String> tags;
  final int? priority;
  final Function(List<String>) onTagsChanged;
  final Function(int?) onPriorityChanged;

  const MetadataPicker({
    super.key,
    required this.tags,
    required this.priority,
    required this.onTagsChanged,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tags', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          children: [
            ...tags.map((tag) => Chip(
                  label: Text(tag),
                  onDeleted: () {
                    final newTags = List<String>.from(tags)..remove(tag);
                    onTagsChanged(newTags);
                  },
                )),
            ActionChip(
              avatar: const Icon(Icons.add, size: 16),
              label: const Text('Add Tag'),
              onPressed: () async {
                final String? newTag = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    final controller = TextEditingController();
                    return AlertDialog(
                      title: const Text('Add Tag'),
                      content: TextField(
                        controller: controller,
                        decoration: const InputDecoration(hintText: 'Tag name'),
                        autofocus: true,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, controller.text),
                          child: const Text('Add'),
                        ),
                      ],
                    );
                  },
                );
                if (newTag != null && newTag.isNotEmpty) {
                  onTagsChanged([...tags, newTag]);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Priority', style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButton<int>(
          value: priority,
          hint: const Text('Select Priority'),
          items: const [
            DropdownMenuItem(value: 1, child: Text('Low')),
            DropdownMenuItem(value: 2, child: Text('Medium')),
            DropdownMenuItem(value: 3, child: Text('High')),
          ],
          onChanged: onPriorityChanged,
        ),
      ],
    );
  }
}
