import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/country/presentation/country_picker_screen.dart';
import '../../features/country/presentation/country_detail_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/personal_context/presentation/personal_context_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/chat',
    routes: [
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // Settings (APP-B1)
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      // APP-D1: Country picker
      GoRoute(
        path: '/country',
        builder: (context, state) => const CountryPickerScreen(),
      ),
      // APP-D2: Country detail (iso2 param)
      GoRoute(
        path: '/country/:iso2',
        builder: (context, state) => CountryDetailScreen(
          iso2: state.pathParameters['iso2']!.toUpperCase(),
        ),
      ),
      // APP-C1 + APP-C2: Personal context + custom instructions
      GoRoute(
        path: '/personal-context',
        builder: (context, state) => const PersonalContextScreen(),
      ),
      // APP-E1 + APP-E2: Server-side history + session resume
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
    ],
  );
});
