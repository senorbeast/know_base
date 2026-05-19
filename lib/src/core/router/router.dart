import 'package:go_router/go_router.dart';
import 'package:cerebro/main.dart';
import 'package:cerebro/src/domain/entities/knowledge_bit.dart';
import 'package:cerebro/src/features/editor/presentation/pages/editor_page.dart';
import 'package:cerebro/src/features/vault/presentation/pages/vault_page.dart';
import 'package:cerebro/src/features/search/presentation/pages/search_page.dart';

final goRouter = GoRouter(
  initialLocation: '/editor',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/editor',
              builder: (context, state) {
                final bit = state.extra as KnowledgeBit?;
                return EditorPage(existingBit: bit);
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/vault',
              builder: (context, state) => const VaultPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
