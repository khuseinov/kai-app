// Foundations stories (colors/type/spacing/motion/tide) — C1-T5.

import 'package:flutter/material.dart';

import '../story_registry.dart';
import '../story_page.dart';
import '../../../../design_system/theme/kai_theme.dart';
import '../../../../design_system/tokens/kai_tokens.dart';
import '../../../../design_system/atoms/atoms.dart';

// ─── private helpers ─────────────────────────────────────────────────────────

/// 44×44 colour swatch with a 1px border.
class _Swatch extends StatelessWidget {
  const _Swatch(this.color, this.borderColor);
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          borderRadius: KaiRadius.br2,
          border: Border.all(color: borderColor),
        ),
      );
}

/// A small looping scale animation demo to illustrate a motion token.
class _MotionDemo extends StatefulWidget {
  const _MotionDemo({required this.duration, required this.curve});
  final Duration duration;
  final Curve curve;

  @override
  State<_MotionDemo> createState() => _MotionDemoState();
}

class _MotionDemoState extends State<_MotionDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _scale = CurvedAnimation(parent: _ctrl, curve: widget.curve)
        .drive(Tween<double>(begin: 0.5, end: 1.0));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, __) => SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: Transform.scale(
            scale: _scale.value,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                gradient: KaiTide.gradient,
                borderRadius: KaiRadius.br2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── 1 · Colors ──────────────────────────────────────────────────────────────

class _ColorsPage extends StatelessWidget {
  const _ColorsPage();

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return StoryPage(
      title: 'Colors',
      layer: 'FOUNDATION',
      blurb: 'Warm light-first palette. Access via KaiTheme.of(context).colors.',
      sections: [
        StorySection('Surfaces', [
          StoryCell('bg #FAFAF9', _Swatch(c.bg, c.line)),
          StoryCell('surface #FFFFFF', _Swatch(c.surface, c.line)),
          StoryCell('surface2 #F3F3F1', _Swatch(c.surface2, c.line)),
          StoryCell('surface3 #ECECEA', _Swatch(c.surface3, c.line)),
        ]),
        StorySection('Ink', [
          StoryCell('ink1 #111114', _Swatch(c.ink1, c.line)),
          StoryCell('ink2 #43434A', _Swatch(c.ink2, c.line)),
          StoryCell('ink3 #76767E', _Swatch(c.ink3, c.line)),
          StoryCell('ink4 #A8A8AE', _Swatch(c.ink4, c.line)),
        ]),
        StorySection('Lines', [
          StoryCell('line #E8E8E5', _Swatch(c.line, c.lineStrong)),
          StoryCell('lineStrong #D2D2CE', _Swatch(c.lineStrong, c.ink4)),
        ]),
        StorySection('Accent', [
          StoryCell('accent #2C5BE5', _Swatch(c.accent, c.line)),
          StoryCell('accentDeep #1E48C7', _Swatch(c.accentDeep, c.line)),
          StoryCell('accentWash #EEF2FD', _Swatch(c.accentWash, c.line)),
          StoryCell('accentLine #C3D2F6', _Swatch(c.accentLine, c.line)),
        ]),
        StorySection('Semantic', [
          StoryCell('positive #1B8E4E', _Swatch(c.positive, c.line)),
          StoryCell('positiveWash #E6F4ED', _Swatch(c.positiveWash, c.line)),
          StoryCell('warning #B57A0B', _Swatch(c.warning, c.line)),
          StoryCell('warningWash #FBF1DC', _Swatch(c.warningWash, c.line)),
          StoryCell('negative #C44A3C', _Swatch(c.negative, c.line)),
          StoryCell('negativeWash #F8E6E3', _Swatch(c.negativeWash, c.line)),
        ]),
        StorySection('Tide', [
          StoryCell(
            'gradient 115°',
            Container(
              width: 120,
              height: 16,
              decoration: const BoxDecoration(
                gradient: KaiTide.gradient,
                borderRadius: KaiRadius.br1,
              ),
            ),
          ),
          StoryCell(
            'gradientCorner 135°',
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                gradient: KaiTide.gradientCorner,
                borderRadius: KaiRadius.br2,
              ),
            ),
          ),
        ]),
      ],
    );
  }
}

// ─── 2 · Typography ───────────────────────────────────────────────────────────

class _TypographyPage extends StatelessWidget {
  const _TypographyPage();

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return StoryPage(
      title: 'Typography',
      layer: 'FOUNDATION',
      blurb: 'Manrope (humanist) + JetBrains Mono. Each factory takes a color.',
      sections: [
        StorySection('Scale', [
          StoryCell(
            'hero · 72 · w600 · Manrope',
            Text('Kai', style: KaiType.hero(color: c.ink1)),
          ),
          StoryCell(
            'display · 56 · w600 · Manrope',
            Text('Tokyo', style: KaiType.display(color: c.ink1)),
          ),
          StoryCell(
            'h1 · 36 · w600 · Manrope',
            Text('Привет', style: KaiType.h1(color: c.ink1)),
          ),
          StoryCell(
            'h2 · 24 · w600 · Manrope',
            Text('Куда летим?', style: KaiType.h2(color: c.ink1)),
          ),
          StoryCell(
            'h3 · 18 · w600 · Manrope',
            Text('Маршрут', style: KaiType.h3(color: c.ink1)),
          ),
          StoryCell(
            'lead · 20 · w400 · Manrope',
            Text('Ваш ИИ-компаньон', style: KaiType.lead(color: c.ink1)),
          ),
          StoryCell(
            'body · 16 · w400 · Manrope',
            Text('Основной текст', style: KaiType.body(color: c.ink1)),
          ),
          StoryCell(
            'small · 14 · w400 · Manrope',
            Text('Малый текст', style: KaiType.small(color: c.ink2)),
          ),
          StoryCell(
            'micro · 12 · w500 · Manrope',
            Text('МЕТКА', style: KaiType.micro(color: c.ink3)),
          ),
          StoryCell(
            'mono · 12 · w400 · JetBrainsMono',
            Text('const x = 42;', style: KaiType.mono(color: c.ink2)),
          ),
        ]),
      ],
    );
  }
}

// ─── 3 · Spacing & Radius ─────────────────────────────────────────────────────

class _SpacingPage extends StatelessWidget {
  const _SpacingPage();

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return StoryPage(
      title: 'Spacing & Radius',
      layer: 'FOUNDATION',
      blurb: '4px-base 11-step spacing scale and radius tokens.',
      sections: [
        StorySection('Spacing', [
          StoryCell('s1 · 4', Container(width: KaiSpace.s1, height: 12, color: c.ink3)),
          StoryCell('s2 · 8', Container(width: KaiSpace.s2, height: 12, color: c.ink3)),
          StoryCell('s3 · 12', Container(width: KaiSpace.s3, height: 12, color: c.ink3)),
          StoryCell('s4 · 16', Container(width: KaiSpace.s4, height: 12, color: c.ink3)),
          StoryCell('s5 · 20', Container(width: KaiSpace.s5, height: 12, color: c.ink3)),
          StoryCell('s6 · 24', Container(width: KaiSpace.s6, height: 12, color: c.ink3)),
          StoryCell('s7 · 32', Container(width: KaiSpace.s7, height: 12, color: c.ink3)),
          StoryCell('s8 · 40', Container(width: KaiSpace.s8, height: 12, color: c.ink3)),
          StoryCell('s9 · 56', Container(width: KaiSpace.s9, height: 12, color: c.ink3)),
          StoryCell('s10 · 80', Container(width: KaiSpace.s10, height: 12, color: c.ink3)),
          StoryCell('s11 · 120', Container(width: KaiSpace.s11, height: 12, color: c.ink3)),
        ]),
        StorySection('Radius', [
          StoryCell(
            'r1 · 6',
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: c.surface2,
                borderRadius: KaiRadius.br1,
                border: Border.all(color: c.line),
              ),
            ),
          ),
          StoryCell(
            'r2 · 10',
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: c.surface2,
                borderRadius: KaiRadius.br2,
                border: Border.all(color: c.line),
              ),
            ),
          ),
          StoryCell(
            'r3 · 14',
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: c.surface2,
                borderRadius: KaiRadius.br3,
                border: Border.all(color: c.line),
              ),
            ),
          ),
          StoryCell(
            'r4 · 20',
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: c.surface2,
                borderRadius: KaiRadius.br4,
                border: Border.all(color: c.line),
              ),
            ),
          ),
          StoryCell(
            'r5 · 28',
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: c.surface2,
                borderRadius: KaiRadius.br5,
                border: Border.all(color: c.line),
              ),
            ),
          ),
          StoryCell(
            'r8 · 8',
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: c.surface2,
                borderRadius: KaiRadius.br8,
                border: Border.all(color: c.line),
              ),
            ),
          ),
          StoryCell(
            'r12 · 12',
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: c.surface2,
                borderRadius: KaiRadius.br12,
                border: Border.all(color: c.line),
              ),
            ),
          ),
          StoryCell(
            'r24 · 24',
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: c.surface2,
                borderRadius: KaiRadius.br24,
                border: Border.all(color: c.line),
              ),
            ),
          ),
          StoryCell(
            'pill · 999',
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: c.surface2,
                borderRadius: KaiRadius.brPill,
                border: Border.all(color: c.line),
              ),
            ),
          ),
        ]),
      ],
    );
  }
}

// ─── 4 · Motion ───────────────────────────────────────────────────────────────

class _MotionPage extends StatelessWidget {
  const _MotionPage();

  @override
  Widget build(BuildContext context) {
    return const StoryPage(
      title: 'Motion',
      layer: 'FOUNDATION',
      blurb: 'Three durations, each with a paired easing curve.',
      sections: [
        StorySection('Durations', [
          StoryCell(
            'standard · 240ms · cubic(.2,0,0,1)',
            _MotionDemo(
              duration: KaiMotion.standard,
              curve: KaiMotion.standardCurve,
            ),
          ),
          StoryCell(
            'ambient · 2600ms · cubic(.4,0,.6,1)',
            _MotionDemo(
              duration: KaiMotion.ambient,
              curve: KaiMotion.ambientCurve,
            ),
          ),
          StoryCell(
            'micro · 120ms · cubic(.4,0,.6,1)',
            _MotionDemo(
              duration: KaiMotion.micro,
              curve: KaiMotion.exitCurve,
            ),
          ),
        ]),
      ],
    );
  }
}

// ─── 5 · Tide ─────────────────────────────────────────────────────────────────

class _TidePage extends StatelessWidget {
  const _TidePage();

  @override
  Widget build(BuildContext context) {
    return const StoryPage(
      title: 'Tide',
      layer: 'FOUNDATION',
      blurb:
          'Two gradient variants + 8 state configs. Ephemeral states auto-revert (loop fix in C1-T7).',
      sections: [
        StorySection('Gradients', [
          StoryCell(
            'gradient · 115°',
            SizedBox(
              width: 160,
              height: 16,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: KaiTide.gradient,
                  borderRadius: KaiRadius.br1,
                ),
              ),
            ),
          ),
          StoryCell(
            'gradientCorner · 135°',
            SizedBox(
              width: 56,
              height: 56,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: KaiTide.gradientCorner,
                  borderRadius: KaiRadius.br2,
                ),
              ),
            ),
          ),
        ]),
        StorySection('States', [
          StoryCell(
            'idle',
            SizedBox(
              width: 80,
              height: 24,
              child: KaiTideCurve(state: KaiTide.idle),
            ),
          ),
          StoryCell(
            'listening',
            SizedBox(
              width: 80,
              height: 24,
              child: KaiTideCurve(state: KaiTide.listening),
            ),
          ),
          StoryCell(
            'thinking',
            SizedBox(
              width: 80,
              height: 24,
              child: KaiTideCurve(state: KaiTide.thinking),
            ),
          ),
          StoryCell(
            'responding',
            SizedBox(
              width: 80,
              height: 24,
              child: KaiTideCurve(state: KaiTide.responding),
            ),
          ),
          StoryCell(
            'success',
            SizedBox(
              width: 80,
              height: 24,
              child: KaiTideCurve(state: KaiTide.success),
            ),
          ),
          StoryCell(
            'error',
            SizedBox(
              width: 80,
              height: 24,
              child: KaiTideCurve(state: KaiTide.error),
            ),
          ),
          StoryCell(
            'memory',
            SizedBox(
              width: 80,
              height: 24,
              child: KaiTideCurve(state: KaiTide.memory),
            ),
          ),
          StoryCell(
            'sleep',
            SizedBox(
              width: 80,
              height: 24,
              child: KaiTideCurve(state: KaiTide.sleep),
            ),
          ),
        ]),
      ],
    );
  }
}

// ─── registry ─────────────────────────────────────────────────────────────────

final List<Story> foundationsStories = [
  Story(
    layer: StoryLayer.foundations,
    name: 'Colors',
    description:
        'Warm light-first palette. All colours via KaiTheme.of(context).colors.',
    build: (_) => const _ColorsPage(),
  ),
  Story(
    layer: StoryLayer.foundations,
    name: 'Typography',
    description: 'Manrope + JetBrains Mono type scale.',
    build: (_) => const _TypographyPage(),
  ),
  Story(
    layer: StoryLayer.foundations,
    name: 'Spacing & Radius',
    description: '4px-base 11-step spacing scale + radius tokens.',
    build: (_) => const _SpacingPage(),
  ),
  Story(
    layer: StoryLayer.foundations,
    name: 'Motion',
    description: 'Duration + easing tokens — standard / ambient / micro.',
    build: (_) => const _MotionPage(),
  ),
  Story(
    layer: StoryLayer.foundations,
    name: 'Tide',
    description: 'Tide gradients and 8 animated state configs.',
    build: (_) => const _TidePage(),
  ),
];
