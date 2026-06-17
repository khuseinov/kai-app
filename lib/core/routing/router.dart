import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kai_app/core/storage/hive_setup.dart';
import 'package:kai_app/core/utils/url_launcher.dart';
import 'package:kai_app/design_system/atoms/atoms.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
import 'package:kai_app/features/dev/storybook/storybook_screen.dart';
import 'package:kai_app/features/dev/theme_showcase_screen.dart';
import 'package:kai_app/features/memory/presentation/pages/memory_page.dart';
import 'package:kai_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:kai_app/features/room/presentation/pages/room_page.dart';
import 'package:kai_app/features/settings/data/models/settings.dart';
import 'package:kai_app/features/settings/presentation/pages/settings_page.dart';
import 'package:kai_app/features/voice/presentation/pages/voice_page.dart';
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
      GoRoute(
        path: '/voice',
        builder: (context, state) => const VoicePage(),
      ),
      GoRoute(
        path: '/_dev',
        builder: (_, __) => const _DevHubScreen(),
      ),
      GoRoute(
        path: '/_dev/theme-showcase',
        builder: (_, __) => const ThemeShowcaseScreen(),
      ),
      GoRoute(
        path: '/_dev/storybook',
        builder: (_, __) => const StorybookScreen(),
      ),
    ],
  );
}

class _DevHubScreen extends StatelessWidget {
  const _DevHubScreen();

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        foregroundColor: c.ink1,
        title: const KaiText.h2('Dev'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(KaiSpace.s5),
        children: [
          _hubTile(
            context,
            label: 'Theme showcase',
            subtitle: 'Tokens, colors, type, space, radius, tide',
            onTap: () => context.go('/_dev/theme-showcase'),
          ),
          const SizedBox(height: KaiSpace.s3),
          _hubTile(
            context,
            label: 'Storybook',
            subtitle: 'All components · sidebar + canvas + knobs',
            onTap: () => context.go('/_dev/storybook'),
          ),
          const SizedBox(height: KaiSpace.s3),
          _hubTile(
            context,
            label: 'Voice Screen',
            subtitle: 'Voice mode with waves, karaoke, and transcript',
            onTap: () => context.go('/voice'),
          ),
          const SizedBox(height: KaiSpace.s3),
          _hubTile(
            context,
            label: 'Spec Viewer',
            subtitle: 'HTML design specs — opens in new tab',
            onTap: () => launchUrlString('/spec-viewer.html'),
          ),
        ],
      ),
    );
  }

  Widget _hubTile(
    BuildContext context, {
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final c = KaiTheme.of(context).colors;
    return Material(
      color: c.surface,
      borderRadius: KaiRadius.br3,
      child: InkWell(
        borderRadius: KaiRadius.br3,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(KaiSpace.s5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KaiText.h3(label),
              const SizedBox(height: KaiSpace.s1),
              KaiText.small(subtitle, color: c.ink3),
            ],
          ),
        ),
      ),
    );
  }
}
