import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../features/chat/presentation/chat_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/companion/presentation/companion_placeholder_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final settings = Hive.box('settings');
  final isOnboarded = settings.get('onboarded') as bool? ?? false;

  return GoRouter(
    initialLocation: isOnboarded ? '/chat' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/companion',
        builder: (context, state) => const CompanionPlaceholderScreen(),
      ),
    ],
  );
});
