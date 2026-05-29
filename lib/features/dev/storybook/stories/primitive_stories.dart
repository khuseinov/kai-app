import 'package:flutter/material.dart';

import '../../../../design_system/atoms/atoms.dart';
import '../../../../design_system/primitives/primitives.dart';
import '../../../../design_system/theme/kai_theme.dart';
import '../../../../design_system/tokens/kai_tokens.dart';
import '../story_registry.dart';
import '_story_helpers.dart';

final List<Story> primitiveStories = [
  Story(
    layer: StoryLayer.primitives,
    name: 'KaiIcon',
    importPath: 'package:kai_app/design_system/primitives/primitives.dart',
    canonFile: 'new-design/foundations.html',
    canonSelector: '.icon-grid svg',
    description:
        'SVG icon primitive — renders a tinted icon from assets/icons/ '
        'using a KaiIconName enum value.',
    variants: ['KaiIcon(name, size, color)'],
    build: (_) => const _KaiIconStory(),
  ),
  Story(
    layer: StoryLayer.primitives,
    name: 'KaiSurface',
    importPath: 'package:kai_app/design_system/primitives/primitives.dart',
    canonFile: 'new-design/foundations.html',
    canonSelector: '.surface-demo',
    description:
        'Themed container primitive — wraps any child with a token-driven '
        'BoxDecoration (color, radius, border, shadow).',
    variants: ['color', 'border: true', 'shadow: KaiShadow.*', 'radius: KaiRadius.*'],
    build: (_) => const _KaiSurfaceStory(),
  ),
  Story(
    layer: StoryLayer.primitives,
    name: 'KaiGradientBar',
    importPath: 'package:kai_app/design_system/primitives/primitives.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.k-who::before',
    description:
        'Tide-gradient rounded pill — used as the Kai "who" glyph (16×4) '
        'and toast tide-bar (10×2.5). Supports a gentle pulse animation.',
    variants: ['static', 'pulse: true', 'width/height custom'],
    build: (_) => const _KaiGradientBarStory(),
  ),
];

// ── Primitives ────────────────────────────────────────────────────────────────

class _KaiIconStory extends StatelessWidget {
  const _KaiIconStory();

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return StorySection(
      title: 'KaiIcon (${KaiIconName.values.length} icons)',
      child: Wrap(
        spacing: KaiSpace.s4,
        runSpacing: KaiSpace.s4,
        children: KaiIconName.values.map((n) {
          final isNew =
              n == KaiIconName.thumbUp || n == KaiIconName.thumbDown;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              KaiIcon(n, size: 24, color: isNew ? c.accent : null),
              const SizedBox(height: 4),
              KaiText.micro(
                n.assetName,
                color: isNew ? c.accent : c.ink3,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _KaiSurfaceStory extends StatelessWidget {
  const _KaiSurfaceStory();

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return StorySection(
      title: 'KaiSurface',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KaiSurface(
            color: c.surface,
            radius: KaiRadius.br4,
            border: true,
            padding: const EdgeInsets.all(KaiSpace.s4),
            child: const KaiText.small('surface + border + br4'),
          ),
          const SizedBox(height: KaiSpace.s3),
          KaiSurface(
            color: c.surface2,
            radius: KaiRadius.br3,
            padding: const EdgeInsets.all(KaiSpace.s4),
            shadow: KaiShadow.button,
            child: const KaiText.small('surface2 + shadow + br3'),
          ),
        ],
      ),
    );
  }
}

class _KaiGradientBarStory extends StatelessWidget {
  const _KaiGradientBarStory();

  @override
  Widget build(BuildContext context) {
    return const StorySection(
      title: 'KaiGradientBar',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              KaiGradientBar(),
              SizedBox(width: KaiSpace.s4),
              KaiText.small('static (16×4)'),
            ],
          ),
          SizedBox(height: KaiSpace.s3),
          Row(
            children: [
              KaiGradientBar(pulse: true),
              SizedBox(width: KaiSpace.s4),
              KaiText.small('pulse: true'),
            ],
          ),
          SizedBox(height: KaiSpace.s3),
          Row(
            children: [
              KaiGradientBar(width: 10, height: 2.5),
              SizedBox(width: KaiSpace.s4),
              KaiText.small('toast size 10×2.5'),
            ],
          ),
        ],
      ),
    );
  }
}
