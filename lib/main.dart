import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'src/core/di/injection.dart';
import 'src/features/editor/presentation/bloc/knowledge_editor_bloc.dart';
import 'src/features/editor/presentation/widgets/content_renderer.dart';
import 'src/features/editor/presentation/widgets/metadata_picker.dart';
import 'src/domain/entities/content_block.dart';
import 'src/domain/entities/knowledge_bit.dart';

import 'package:cerebro/src/features/vault/presentation/bloc/vault_bloc.dart';
import 'package:cerebro/src/features/vault/presentation/pages/vault_page.dart';
import 'package:cerebro/src/features/search/presentation/bloc/search_bloc.dart';
import 'package:cerebro/src/features/search/presentation/pages/search_page.dart';

import 'package:cerebro/src/data/services/media_service.dart';

import 'package:cerebro/src/core/router/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<KnowledgeEditorBloc>()),
        BlocProvider(create: (context) => getIt<VaultBloc>()),
        BlocProvider(create: (context) => getIt<SearchBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Cerebro',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        routerConfig: goRouter,
      ),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const EditorPage(),
    const VaultPage(),
    const SearchPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 1) {
            context.read<VaultBloc>().add(const VaultEvent.loadRequested());
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Editor'),
          BottomNavigationBarItem(icon: Icon(Icons.storage), label: 'Vault'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
      ),
    );
  }
}

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final TextEditingController _titleController = TextEditingController();
  List<ContentBlock> _blocks = [
    const ContentBlock.text('Enter your notes here...'),
  ];
  List<String> _tags = [];
  int? _priority = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cerebro Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              if (_titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a title')),
                );
                return;
              }
              final bit = KnowledgeBit(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: _titleController.text,
                blocks: _blocks,
                tags: _tags,
                priority: _priority,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              context.read<KnowledgeEditorBloc>().add(
                KnowledgeEditorEvent.saveRequested(bit),
              );
            },
          ),
        ],
      ),
      body: BlocListener<KnowledgeEditorBloc, KnowledgeEditorState>(
        listener: (context, state) {
          state.whenOrNull(
            success: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved successfully!')),
              );
              context.read<VaultBloc>().add(const VaultEvent.loadRequested());
            },
            failure: (message) => ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $message'))),
          );
        },
        child: SingleChildScrollView(
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
              ),
              const SizedBox(height: 16),
              MetadataPicker(
                tags: _tags,
                priority: _priority,
                onTagsChanged: (tags) => setState(() => _tags = tags),
                onPriorityChanged: (priority) =>
                    setState(() => _priority = priority),
              ),
              const Divider(height: 32),
              ContentRenderer(
                blocks: _blocks,
                onBlockChanged: (index, newBlock) {
                  setState(() {
                    _blocks[index] = newBlock;
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton.filledTonal(
                    onPressed: () {
                      setState(() {
                        _blocks = [..._blocks, const ContentBlock.text('')];
                      });
                    },
                    icon: const Icon(Icons.add_comment),
                    tooltip: 'Add Text',
                  ),
                  IconButton.filledTonal(
                    onPressed: () async {
                      final path = await getIt<MediaService>()
                          .pickAndEncryptImage();
                      if (path != null) {
                        setState(() {
                          _blocks = [
                            ..._blocks,
                            ContentBlock.image(encryptedPath: path),
                          ];
                        });
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
                        setState(() {
                          _blocks = [
                            ..._blocks,
                            ContentBlock.file(
                              encryptedPath: fileData['path']!,
                              fileName: fileData['name']!,
                            ),
                          ];
                        });
                      }
                    },
                    icon: const Icon(Icons.attach_file),
                    tooltip: 'Add File',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
