import 'package:go_router/go_router.dart';
import 'package:kai_app/core/storage/hive_setup.dart';
import 'package:kai_app/features/memory/presentation/pages/memory_page.dart';
import 'package:kai_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:kai_app/features/room/presentation/pages/room_page.dart';
import 'package:kai_app/features/settings/data/models/settings.dart';
import 'package:kai_app/features/settings/presentation/pages/settings_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(RouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        redirect: (context, state) {
          final settings =
              HiveSetup.settings.get(HiveSetup.settingsKey) ?? const AppSettings();
          return settings.onboarded ? '/room' : '/onboarding';
        },
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/room',
        builder: (context, state) => const RoomPage(),
      ),
      GoRoute(
        path: '/room/:tripId',
        builder: (context, state) =>
            RoomPage(tripId: state.pathParameters['tripId']),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/memory',
        builder: (context, state) => const MemoryPage(),
      ),
    ],
  );
}
