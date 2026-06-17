// Shared helper widgets used by multiple story layer files.
// Not exported publicly — imported directly by each stories/*.dart file.

import 'package:flutter/material.dart';

import 'package:kai_app/design_system/atoms/atoms.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

// ── Shared section header ─────────────────────────────────────────────────────

class SpecSection extends StatelessWidget {
  const SpecSection({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: KaiType.micro(color: c.ink3)),
        const SizedBox(height: KaiSpace.s3),
        child,
      ],
    );
  }
}

// ── Inline spec annotation — monospace muted text ─────────────────────────────

class SpecNote extends StatelessWidget {
  const SpecNote(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        '· $text',
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 9,
          color: c.ink3,
          height: 1.5,
        ),
      ),
    );
  }
}

// ── Unbuilt screen spec previews ──────────────────────────────────────────────
// VoiceCanonPreview, TripDetailCanonPreview, and ForkCardCanonPreview have been
// removed — their content is now covered by real component stories:
//   Voice     → KaiKaraokeText (atom) — atom_stories.dart
//   Fork      → KaiForkChip, KaiForkScoreDots (atoms) + KaiForkCard (molecule)
//   TripDetail→ KaiBudgetBar (atom) — atom_stories.dart
// Memory remains as a screen-level placeholder until the full screen is built.

/// Memory Screen spec-preview.
class MemoryCanonPreview extends StatelessWidget {
  const MemoryCanonPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;

    return SpecSection(
      title: 'Memory Screen — spec values (NOT YET BUILT)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(KaiSpace.s3),
            decoration: BoxDecoration(
              color: c.warningWash,
              borderRadius: KaiRadius.br2,
              border: Border.all(color: c.warning.withValues(alpha: 0.4)),
            ),
            child: KaiText.micro(
              'NOT YET BUILT — canon: new-design/memory.html',
              color: c.warning,
            ),
          ),
          const SizedBox(height: KaiSpace.s4),

          // Memory hero card demo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.surface2,
              borderRadius: KaiRadius.br4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KaiText.small('Путешествия', color: c.ink1),
                const SizedBox(height: 2),
                KaiText.micro('3 воспоминания', color: c.ink3),
              ],
            ),
          ),
          const SizedBox(height: KaiSpace.s2),
          const SpecNote('Memory hero: r16 pad14; title 14px w600 ink1; sub 11px ink3'),

          const SizedBox(height: KaiSpace.s3),

          // Fact item demo
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 11, vertical: 9,),
            decoration: BoxDecoration(
              color: c.surface2,
              borderRadius: KaiRadius.br8,
              border: Border.all(color: c.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KaiText.small(
                    'Предпочитает прямые рейсы без пересадок',
                    color: c.ink1,),
                const SizedBox(height: 2),
                KaiText.micro('из chat · 2 дня назад', color: c.ink3),
              ],
            ),
          ),
          const SizedBox(height: KaiSpace.s2),
          const SpecNote('.fact-item: r8, pad 9/11; body 13px ink1; source 9.5px ink3'),

          const SizedBox(height: KaiSpace.s3),

          // Forget row demo
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 11,),
            decoration: BoxDecoration(
              color: c.negativeWash,
              borderRadius: KaiRadius.br8,
            ),
            child: KaiText.small('Забыть это воспоминание', color: c.negative),
          ),
          const SizedBox(height: KaiSpace.s2),
          const SpecNote('"Forget" row: r8, pad 11/12, negative color'),

          const SizedBox(height: KaiSpace.s3),
          const SpecNote('Search bar: 12.5px ink3, r10, pad 9/12, bg surface-2 = KaiInput.line'),
          const SpecNote('Fact groups: bg surface-2, r12, pad 4px'),
          const SpecNote('Toggle: KaiToggle — positive (green = on)'),
          const SpecNote('App bar: ttl 13px w600; ic-btn: circle bg surface-2'),
          const SizedBox(height: KaiSpace.s3),
          const SpecNote('Dart components to reuse: KaiInput.line, KaiToggle, KaiButton.ink(fullWidth), KaiAvatar'),
          const SpecNote('NEW widgets needed: MemoryFactGroup, MemoryFactItem, MemoryHero'),
        ],
      ),
    );
  }
}

