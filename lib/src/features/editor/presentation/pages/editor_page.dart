import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cerebro/src/core/di/injection.dart';
import 'package:cerebro/src/data/services/media_service.dart';
import 'package:cerebro/src/domain/entities/content_block.dart';
import 'package:cerebro/src/domain/entities/knowledge_bit.dart';
import 'package:cerebro/src/features/editor/presentation/bloc/knowledge_editor_bloc.dart';
import 'package:cerebro/src/features/editor/presentation/widgets/content_renderer.dart';
import 'package:cerebro/src/features/editor/presentation/widgets/metadata_picker.dart';
import 'package:cerebro/src/features/vault/presentation/bloc/vault_bloc.dart';

class EditorPage extends StatefulWidget {
  final KnowledgeBit? existingBit;
  const EditorPage({super.key, this.existingBit});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<KnowledgeEditorBloc>().add(
      KnowledgeEditorEvent.initialize(existingBit: widget.existingBit),
    );
    final initialTitle = context.read<KnowledgeEditorBloc>().state.bit.title;
    _titleController.text = initialTitle;
  }

  @override
  void didUpdateWidget(covariant EditorPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.existingBit != oldWidget.existingBit && widget.existingBit != null) {
      context.read<KnowledgeEditorBloc>().add(
        KnowledgeEditorEvent.initialize(existingBit: widget.existingBit),
      );
      _titleController.text = widget.existingBit!.title;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cerebro Editor'),
        actions: [
          BlocBuilder<KnowledgeEditorBloc, KnowledgeEditorState>(
            builder: (context, state) {
              if (state.saveStatus == SaveStatus.saving) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                );
              }
              if (state.saveStatus == SaveStatus.failure) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Tooltip(
                    message: state.errorMessage ?? 'Failed to auto-save',
                    child: const Icon(Icons.cloud_off, color: Colors.red),
                  ),
                );
              }
              if (state.isDirty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Icon(Icons.cloud_queue, color: Colors.grey),
                );
              }
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(Icons.cloud_done, color: Colors.green),
              );
            },
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<KnowledgeEditorBloc, KnowledgeEditorState>(
            listenWhen: (previous, current) =>
                previous.saveStatus != current.saveStatus &&
                current.saveStatus == SaveStatus.success,
            listener: (context, state) {
              context.read<VaultBloc>().add(const VaultEvent.loadRequested());
            },
          ),
          BlocListener<KnowledgeEditorBloc, KnowledgeEditorState>(
            listenWhen: (previous, current) => previous.bit.title != current.bit.title,
            listener: (context, state) {
              if (_titleController.text != state.bit.title) {
                _titleController.text = state.bit.title;
              }
            },
          ),
        ],
        child: BlocBuilder<KnowledgeEditorBloc, KnowledgeEditorState>(
          builder: (context, state) {
            final bit = state.bit;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Bit Title',
                      border: InputBorder.none,
                    ),
                    style: Theme.of(context).textTheme.headlineMedium,
                    onChanged: (title) {
                      context.read<KnowledgeEditorBloc>().add(
                            KnowledgeEditorEvent.titleChanged(title),
                          );
                    },
                  ),
                  const SizedBox(height: 16),
                  MetadataPicker(
                    tags: bit.tags,
                    priority: bit.priority,
                    onTagsChanged: (tags) {
                      context.read<KnowledgeEditorBloc>().add(KnowledgeEditorEvent.tagsChanged(tags));
                    },
                    onPriorityChanged: (priority) {
                      context.read<KnowledgeEditorBloc>().add(KnowledgeEditorEvent.priorityChanged(priority));
                    },
                  ),
                  const Divider(height: 32),
                  ContentRenderer(
                    blocks: bit.blocks,
                    onBlockChanged: (index, newBlock) {
                      context.read<KnowledgeEditorBloc>().add(
                            KnowledgeEditorEvent.blockUpdated(index, newBlock),
                          );
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton.filledTonal(
                        onPressed: () {
                          context.read<KnowledgeEditorBloc>().add(
                            const KnowledgeEditorEvent.blockAdded(ContentBlock.text('')),
                          );
                        },
                        icon: const Icon(Icons.add_comment),
                        tooltip: 'Add Text',
                      ),
                      IconButton.filledTonal(
                        onPressed: () async {
                          final path = await getIt<MediaService>()
                              .pickAndEncryptImage();
                          if (path != null) {
                            if (!context.mounted) return;
                            context.read<KnowledgeEditorBloc>().add(
                              KnowledgeEditorEvent.blockAdded(
                                ContentBlock.image(encryptedPath: path),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.add_a_photo),
                        tooltip: 'Add Image',
                      ),
                      IconButton.filledTonal(
                        onPressed: () async {
                          final fileData = await getIt<MediaService>()
                              .pickAndEncryptFile();
                          if (fileData != null) {
                            if (!context.mounted) return;
                            context.read<KnowledgeEditorBloc>().add(
                              KnowledgeEditorEvent.blockAdded(
                                ContentBlock.file(
                                  encryptedPath: fileData['path']!,
                                  fileName: fileData['name']!,
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.attach_file),
                        tooltip: 'Add File',
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.read<KnowledgeEditorBloc>().add(const KnowledgeEditorEvent.reset());
        },
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        icon: const Icon(Icons.add),
        label: const Text('New Bit'),
        tooltip: 'Create a new blank bit',
      ),
    );
  }
}
