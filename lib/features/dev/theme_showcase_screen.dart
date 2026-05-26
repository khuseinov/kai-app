import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/root.dart';
import '../../design_system/theme/kai_theme.dart';
import '../../design_system/tokens/kai_tokens.dart';

/// Phase 1 visual demo of all tokens + theme-mode toggle.
class ThemeShowcaseScreen extends ConsumerWidget {
  const ThemeShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = KaiTheme.of(context);
    final c = tokens.colors;
    final mode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        foregroundColor: c.ink1,
        title: Text('Theme showcase', style: KaiType.h2(color: c.ink1)),
        actions: [
          IconButton(
            tooltip: 'Cycle theme mode (current: ${mode.name})',
            icon: Icon(_iconForMode(mode), color: c.ink1),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state = _nextMode(mode);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(KaiSpace.s5),
        children: [
          _Section(title: 'Colors', child: _ColorsGrid(c: c)),
          const SizedBox(height: KaiSpace.s7),
          _Section(title: 'Type', child: _TypeBlock(color: c.ink1)),
          const SizedBox(height: KaiSpace.s7),
          _Section(title: 'Space', child: _SpaceBlock(color: c.accent)),
          const SizedBox(height: KaiSpace.s7),
          _Section(
            title: 'Radius',
            child: _RadiusBlock(color: c.accentWash, border: c.line),
          ),
          const SizedBox(height: KaiSpace.s7),
          const _Section(title: 'Tide', child: _TideBlock()),
          const SizedBox(height: KaiSpace.s11),
        ],
      ),
    );
  }

  ThemeMode _nextMode(ThemeMode m) {
    switch (m) {
      case ThemeMode.system:
        return ThemeMode.light;
      case ThemeMode.light:
        return ThemeMode.dark;
      case ThemeMode.dark:
        return ThemeMode.system;
    }
  }

  IconData _iconForMode(ThemeMode m) {
    switch (m) {
      case ThemeMode.system:
        return Icons.brightness_auto_outlined;
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: KaiType.micro(color: c.ink3),
        ),
        const SizedBox(height: KaiSpace.s3),
        child,
      ],
    );
  }
}

class _ColorsGrid extends StatelessWidget {
  const _ColorsGrid({required this.c});
  final KaiColorTokens c;

  @override
  Widget build(BuildContext context) {
    final swatches = <(String, Color)>[
      ('bg', c.bg),
      ('surface', c.surface),
      ('surface2', c.surface2),
      ('surface3', c.surface3),
      ('ink1', c.ink1),
      ('ink2', c.ink2),
      ('ink3', c.ink3),
      ('ink4', c.ink4),
      ('line', c.line),
      ('lineStrong', c.lineStrong),
      ('accent', c.accent),
      ('accentDeep', c.accentDeep),
      ('accentWash', c.accentWash),
      ('accentLine', c.accentLine),
      ('positive', c.positive),
      ('positiveWash', c.positiveWash),
      ('warning', c.warning),
      ('warningWash', c.warningWash),
      ('negative', c.negative),
      ('negativeWash', c.negativeWash),
    ];
    return Wrap(
      spacing: KaiSpace.s3,
      runSpacing: KaiSpace.s3,
      children: swatches
          .map(
            (s) => SizedBox(
              width: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: s.$2,
                      borderRadius: KaiRadius.br2,
                      border: Border.all(color: c.line),
                    ),
                  ),
                  const SizedBox(height: KaiSpace.s1),
                  Text(s.$1, style: KaiType.small(color: c.ink2)),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _TypeBlock extends StatelessWidget {
  const _TypeBlock({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('hero · 72', style: KaiType.hero(color: color)),
        const SizedBox(height: KaiSpace.s2),
        Text('h1 · 36', style: KaiType.h1(color: color)),
        const SizedBox(height: KaiSpace.s2),
        Text('h2 · 24', style: KaiType.h2(color: color)),
        const SizedBox(height: KaiSpace.s2),
        Text(
          'body · 16 — the quick brown fox',
          style: KaiType.body(color: color),
        ),
        const SizedBox(height: KaiSpace.s1),
        Text('small · 14', style: KaiType.small(color: color)),
        const SizedBox(height: KaiSpace.s1),
        Text('MICRO · 12', style: KaiType.micro(color: color)),
        const SizedBox(height: KaiSpace.s1),
        Text('mono · 12 → fn()', style: KaiType.mono(color: color)),
      ],
    );
  }
}

class _SpaceBlock extends StatelessWidget {
  const _SpaceBlock({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    const tokens = <(String, double)>[
      ('s1', KaiSpace.s1),
      ('s2', KaiSpace.s2),
      ('s3', KaiSpace.s3),
      ('s4', KaiSpace.s4),
      ('s5', KaiSpace.s5),
      ('s6', KaiSpace.s6),
      ('s7', KaiSpace.s7),
      ('s8', KaiSpace.s8),
      ('s9', KaiSpace.s9),
      ('s10', KaiSpace.s10),
      ('s11', KaiSpace.s11),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tokens
          .map(
            (t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      t.$1,
                      style: KaiType.small(color: color),
                    ),
                  ),
                  Container(
                    width: t.$2,
                    height: 12,
                    color: color,
                  ),
                  const SizedBox(width: KaiSpace.s2),
                  Text(
                    '${t.$2.toInt()}px',
                    style: KaiType.mono(color: color),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _RadiusBlock extends StatelessWidget {
  const _RadiusBlock({required this.color, required this.border});
  final Color color;
  final Color border;

  @override
  Widget build(BuildContext context) {
    const tokens = <(String, double)>[
      ('r1', KaiRadius.r1),
      ('r2', KaiRadius.r2),
      ('r3', KaiRadius.r3),
      ('r4', KaiRadius.r4),
      ('r5', KaiRadius.r5),
      ('pill', KaiRadius.pill),
    ];
    return Wrap(
      spacing: KaiSpace.s4,
      runSpacing: KaiSpace.s4,
      children: tokens
          .map(
            (t) => Column(
              children: [
                Container(
                  width: 72,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(color: border),
                    borderRadius: BorderRadius.circular(t.$2),
                  ),
                ),
                const SizedBox(height: KaiSpace.s1),
                Text(t.$1, style: KaiType.small(color: border)),
              ],
            ),
          )
          .toList(growable: false),
    );
  }
}

class _TideBlock extends StatelessWidget {
  const _TideBlock();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 28,
      decoration: BoxDecoration(
        gradient: KaiTide.gradient,
        borderRadius: KaiRadius.brPill,
      ),
    );
  }
}
