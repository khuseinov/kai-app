import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/atoms/kai_text.dart';
import '../../design_system/theme/kai_theme.dart';
import '../../design_system/tokens/kai_tokens.dart';
import '../../features/dev/atoms_showcase_screen.dart';
import '../../features/dev/molecules_showcase_screen.dart';
import '../../features/dev/theme_showcase_screen.dart';

/// Phase 2 router stub.
///
/// `/` redirects to `/_dev` (a simple hub of dev showcases).
/// Real app routes land in Phase 5.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/_dev',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        redirect: (_, __) => '/_dev',
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
        path: '/_dev/atoms',
        builder: (_, __) => const AtomsShowcaseScreen(),
      ),
      GoRoute(
        path: '/_dev/molecules',
        builder: (_, __) => const MoleculesShowcaseScreen(),
      ),
    ],
  );
});

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
            label: 'Atoms',
            subtitle: 'KaiText, KaiIcon, KaiButton, KaiInput, KaiBubble, '
                'KaiTideCurve',
            onTap: () => context.go('/_dev/atoms'),
          ),
          const SizedBox(height: KaiSpace.s3),
          _hubTile(
            context,
            label: 'Molecules',
            subtitle: 'ComposeIsland, NavItem, SourceCard, AlertCard, '
                'CareBlock',
            onTap: () => context.go('/_dev/molecules'),
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
