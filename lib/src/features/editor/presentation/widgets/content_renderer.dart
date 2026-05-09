import 'package:flutter/material.dart';
import '../../../../domain/entities/content_block.dart';
import 'text_block_editor.dart';

class ContentRenderer extends StatelessWidget {
  final List<ContentBlock> blocks;
  final Function(int, ContentBlock)? onBlockChanged;

  const ContentRenderer({
    super.key,
    required this.blocks,
    this.onBlockChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: blocks.length,
      itemBuilder: (context, index) {
        final block = blocks[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: block.when(
            text: (data) => TextBlockEditor(
              initialText: data,
              onChanged: (newText) {
                if (onBlockChanged != null) {
                  onBlockChanged!(index, ContentBlock.text(newText));
                }
              },
            ),
            image: (path, caption) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // In a real app, this would be an encrypted image loader
                Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.image, size: 50)),
                ),
                if (caption != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      caption,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
            file: (path, fileName) => ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: Text(fileName),
              subtitle: const Text('Encrypted File'),
              trailing: const Icon(Icons.download),
              onTap: () {
                // Implement file decryption and opening
              },
            ),
          ),
        );
      },
    );
  }
}
