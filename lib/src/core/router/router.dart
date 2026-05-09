import 'package:go_router/go_router.dart';
import '../../../main.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScaffold(),
    ),
    // You can add more routes here, like /bit/:id for deep linking
  ],
);
