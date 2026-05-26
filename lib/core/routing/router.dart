import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dev/theme_showcase_screen.dart';

/// Phase 1 router stub.
///
/// Single route `/` redirecting to `/_dev/theme-showcase`. Real app routes
/// land in Phase 5.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/_dev/theme-showcase',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        redirect: (_, __) => '/_dev/theme-showcase',
      ),
      GoRoute(
        path: '/_dev/theme-showcase',
        builder: (_, __) => const ThemeShowcaseScreen(),
      ),
    ],
  );
});
