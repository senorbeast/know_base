import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'src/core/di/injection.dart';
import 'src/features/editor/presentation/bloc/knowledge_editor_bloc.dart';

import 'package:cerebro/src/features/vault/presentation/bloc/vault_bloc.dart';
import 'package:cerebro/src/features/search/presentation/bloc/search_bloc.dart';

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

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            context.read<VaultBloc>().add(const VaultEvent.loadRequested());
          }
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
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


