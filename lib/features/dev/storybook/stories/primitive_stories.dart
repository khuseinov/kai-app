import 'package:flutter/material.dart';

import '../../../../design_system/atoms/atoms.dart';
import '../../../../design_system/primitives/primitives.dart';
import '../../../../design_system/theme/kai_theme.dart';
import '../../../../design_system/tokens/kai_tokens.dart';
import '../story_page.dart';
import '../story_registry.dart';

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
    variants: const ['KaiIcon(name, size, color)'],
    props: const [
      PropDoc('name', 'KaiIconName', 'required', 'Which SVG asset to render'),
      PropDoc('size', 'double', '18', 'Glyph size in logical pixels'),
      PropDoc('color', 'Color?', 'ink2', 'Tint color; defaults to theme ink2'),
    ],
    build: (_) => StoryPage(
      title: 'KaiIcon',
      layer: 'PRIMITIVE',
      blurb: 'Single SVG source for all 33 icons. Used by atoms and molecules — '
          'never duplicated path strings.',
      sections: [
        StorySection(
          'All icons',
          KaiIconName.values
              .map((n) => StoryCell(n.assetName, KaiIcon(n, size: 24)))
              .toList(),
        ),
        const StorySection('Sizes', [
          StoryCell('12', KaiIcon(KaiIconName.send, size: 12)),
          StoryCell('18 (default)', KaiIcon(KaiIconName.send, size: 18)),
          StoryCell('24', KaiIcon(KaiIconName.send, size: 24)),
          StoryCell('32', KaiIcon(KaiIconName.send, size: 32)),
        ]),
      ],
      usage: 'KaiIcon(KaiIconName.send, size: 18)',
      props: const [
        PropDoc('name', 'KaiIconName', 'required', 'Which SVG asset to render'),
        PropDoc('size', 'double', '18', 'Glyph size in logical pixels'),
        PropDoc('color', 'Color?', 'ink2', 'Tint color; defaults to theme ink2'),
      ],
    ),
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
    variants: const ['color', 'border: true', 'shadow: KaiShadow.*', 'radius: KaiRadius.*'],
    props: const [
      PropDoc('child', 'Widget', 'required', 'Content inside the surface'),
      PropDoc('color', 'Color', 'required', 'Background fill — pass a surface token'),
      PropDoc('radius', 'BorderRadius?', 'null', 'Corner radius, e.g. KaiRadius.br4'),
      PropDoc('border', 'bool', 'false', '1px Border.all in the theme line color'),
      PropDoc('shadow', 'List<BoxShadow>?', 'null', 'e.g. KaiShadow.button'),
      PropDoc('padding', 'EdgeInsetsGeometry?', 'null', 'Inner padding'),
    ],
    build: (_) => const StoryPage(
      title: 'KaiSurface',
      layer: 'PRIMITIVE',
      blurb: 'Themed container building block — the base for cards, wells, and '
          'sheet bodies. Caller supplies color; component never reads theme for color.',
      sections: [
        StorySection('Variants', [
          StoryCell('surface + border + br4', _SurfaceDemo(
            colorKey: 'surface', radiusKey: 'br4', border: true)),
          StoryCell('surface2 + shadow + br3', _SurfaceDemo(
            colorKey: 'surface2', radiusKey: 'br3', shadow: KaiShadow.button)),
          StoryCell('surface3 + border + br2', _SurfaceDemo(
            colorKey: 'surface3', radiusKey: 'br2', border: true)),
        ]),
        StorySection('With content', [
          StoryCell('surface2 card', _SurfaceContentDemo()),
        ]),
      ],
      usage: 'KaiSurface(\n'
          '  color: KaiTheme.of(context).colors.surface,\n'
          '  radius: KaiRadius.br4,\n'
          '  border: true,\n'
          '  padding: const EdgeInsets.all(KaiSpace.s4),\n'
          '  child: KaiText.body("Hello"),\n'
          ')',
      props: [
        PropDoc('child', 'Widget', 'required', 'Content inside the surface'),
        PropDoc('color', 'Color', 'required', 'Background fill — pass a surface token'),
        PropDoc('radius', 'BorderRadius?', 'null', 'Corner radius, e.g. KaiRadius.br4'),
        PropDoc('border', 'bool', 'false', '1px Border.all in the theme line color'),
        PropDoc('shadow', 'List<BoxShadow>?', 'null', 'e.g. KaiShadow.button'),
        PropDoc('padding', 'EdgeInsetsGeometry?', 'null', 'Inner padding'),
      ],
    ),
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
    variants: const ['static', 'pulse: true', 'width/height custom'],
    props: const [
      PropDoc('width', 'double', '16', 'Pill width in logical pixels'),
      PropDoc('height', 'double', '4', 'Pill height in logical pixels'),
      PropDoc('pulse', 'bool', 'false', 'Gentle scale-breathe animation'),
    ],
    build: (_) => const StoryPage(
      title: 'KaiGradientBar',
      layer: 'PRIMITIVE',
      blurb: 'Tide-gradient pill — used as the Kai "who" glyph (16×4) and '
          'toast tide-bar (10×2.5). Pulse drives a gentle breathe cycle.',
      sections: [
        StorySection('Variants', [
          StoryCell('static · who glyph (16×4)', KaiGradientBar()),
          StoryCell('pulse: true', KaiGradientBar(pulse: true)),
          StoryCell('toast size (10×2.5)', KaiGradientBar(width: 10, height: 2.5)),
        ]),
        StorySection('Custom sizes', [
          StoryCell('32×6', KaiGradientBar(width: 32, height: 6)),
          StoryCell('64×4', KaiGradientBar(width: 64, height: 4)),
        ]),
      ],
      usage: 'KaiGradientBar()                      // who glyph\n'
          'KaiGradientBar(width: 10, height: 2.5) // toast bar\n'
          'KaiGradientBar(pulse: true)             // animated',
      props: [
        PropDoc('width', 'double', '16', 'Pill width in logical pixels'),
        PropDoc('height', 'double', '4', 'Pill height in logical pixels'),
        PropDoc('pulse', 'bool', 'false', 'Gentle scale-breathe animation'),
      ],
    ),
  ),
];

// ── KaiSurface demo helpers (context-aware — can't be const) ─────────────────

class _SurfaceDemo extends StatelessWidget {
  const _SurfaceDemo({
    required this.colorKey,
    required this.radiusKey,
    this.border = false,
    this.shadow,
  });

  final String colorKey;
  final String radiusKey;
  final bool border;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final color = switch (colorKey) {
      'surface2' => c.surface2,
      'surface3' => c.surface3,
      _ => c.surface,
    };
    final radius = switch (radiusKey) {
      'br2' => KaiRadius.br2,
      'br3' => KaiRadius.br3,
      _ => KaiRadius.br4,
    };
    return KaiSurface(
      color: color,
      radius: radius,
      border: border,
      shadow: shadow,
      padding: const EdgeInsets.all(KaiSpace.s4),
      child: KaiText.small('$colorKey + $radiusKey'),
    );
  }
}

class _SurfaceContentDemo extends StatelessWidget {
  const _SurfaceContentDemo();

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return KaiSurface(
      color: c.surface2,
      radius: KaiRadius.br4,
      border: true,
      padding: const EdgeInsets.all(KaiSpace.s4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KaiText.h3('Surface child content'),
          const SizedBox(height: KaiSpace.s2),
          KaiText.body('Any widget goes here.', color: c.ink2),
        ],
      ),
    );
  }
}
