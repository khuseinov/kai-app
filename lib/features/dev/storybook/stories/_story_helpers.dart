// Shared helper widgets used by multiple story layer files.
// Not exported publicly — imported directly by each stories/*.dart file.

import 'package:flutter/material.dart';

import '../../../../design_system/atoms/atoms.dart';
import '../../../../design_system/theme/kai_theme.dart';
import '../../../../design_system/tokens/kai_tokens.dart';

// ── Shared section header ─────────────────────────────────────────────────────

class SpecSection extends StatelessWidget {
  const SpecSection({super.key, required this.title, required this.child});

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

/// Voice Screen spec-preview.
///
/// Always dark bg (#08080A) — never responds to theme.
/// Shows key computed values from the Playwright audit so agents know exactly
/// what to build when implementing the voice screen.
class VoiceCanonPreview extends StatelessWidget {
  const VoiceCanonPreview({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF08080A); // voice screen bg — always dark
    const white32 = Color(0x52FFFFFF); // rgba(255,255,255,0.32) NEXT words
    const white40 = Color(0x66FFFFFF); // rgba(255,255,255,0.40) timestamps
    const white25 = Color(0x40FFFFFF); // rgba(255,255,255,0.25) hint labels
    const karaokeNowBg = Color(0x47F4B589); // tide-3 @ 0.28 opacity
    const karaokeNowText = KaiTide.stop3; // tide-3 warm horizon

    return SpecSection(
      title: 'Voice Screen — spec values (NOT YET BUILT)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NOT YET BUILT banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(KaiSpace.s3),
            decoration: BoxDecoration(
              color: const Color(0x1FD69E3E), // warning wash (dark)
              borderRadius: KaiRadius.br2,
              border: Border.all(
                color: const Color(0xFFD69E3E).withValues(alpha: 0.4),
              ),
            ),
            child: const Text(
              'NOT YET BUILT — canon: new-design/voice.html',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 10,
                color: Color(0xFFD69E3E),
              ),
            ),
          ),
          const SizedBox(height: KaiSpace.s4),

          // Dark surface preview
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: bg,
              borderRadius: KaiRadius.br3,
            ),
            padding: const EdgeInsets.all(KaiSpace.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // bg label
                const Text(
                  'bg: #08080A — ALWAYS DARK, never theme-aware',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 9,
                    color: white40,
                  ),
                ),
                const SizedBox(height: KaiSpace.s4),

                // Karaoke row
                Wrap(
                  spacing: KaiSpace.s2,
                  runSpacing: KaiSpace.s2,
                  children: [
                    // NOW word
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: const BoxDecoration(
                        color: karaokeNowBg,
                        borderRadius: KaiRadius.br1,
                      ),
                      child: const Text(
                        'NOW',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: karaokeNowText,
                        ),
                      ),
                    ),
                    // NEXT words
                    ...['next', 'words', 'here'].map(
                      (w) => Text(
                        w,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: white32,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KaiSpace.s3),

                // Spec notes
                const SpecNote('Karaoke NOW: bg rgba(244,181,137,0.28) = tide-3@0.28, r4, pad 1/5, 16px w500 white'),
                const SpecNote('Karaoke NEXT: color rgba(255,255,255,0.32), same font'),
                const SizedBox(height: KaiSpace.s2),
                const SpecNote('Transcript events: pad 9/22/9/52'),
                const SpecNote('Timestamp: 8.5px w500, rgba(white,0.4) = Color(0x66FFFFFF)'),
                const SpecNote('Hint labels: 9px, rgba(white,0.25) = Color(0x40FFFFFF)'),
                const SizedBox(height: KaiSpace.s2),

                // Hint label demo
                const Text(
                  'tap to speak / swipe',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 9,
                    color: white25,
                  ),
                ),
                const SizedBox(height: KaiSpace.s2),
                // Timestamp demo
                const Text(
                  '0:04',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 8.5,
                    fontWeight: FontWeight.w500,
                    color: white40,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: KaiSpace.s3),
          const SpecNote('Dart components to reuse: KaiTideCurve (voice state), KaiButton.ink (stop), KaiText'),
          const SpecNote('NEW widgets needed: VoiceKaraoke, VoiceTranscriptRow, VoiceHintLabel'),
        ],
      ),
    );
  }
}

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
                horizontal: 11, vertical: 9),
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
                    color: c.ink1),
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
                horizontal: 12, vertical: 11),
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

/// Trip Detail Screen spec-preview.
class TripDetailCanonPreview extends StatelessWidget {
  const TripDetailCanonPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;

    return SpecSection(
      title: 'Trip Detail Screen — spec values (NOT YET BUILT)',
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
              'NOT YET BUILT — canon: new-design/trip-detail.html',
              color: c.warning,
            ),
          ),
          const SizedBox(height: KaiSpace.s4),

          // Trip hero demo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(KaiSpace.s4),
            decoration: BoxDecoration(
              color: c.surface2,
              borderRadius: BorderRadius.circular(KaiRadius.r4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Glyph (tide-corner gradient circle)
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        gradient: KaiTide.gradientCorner,
                        borderRadius: KaiRadius.brPill,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Т',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                    const SizedBox(width: KaiSpace.s3),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Токио 2026',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: c.ink1,
                          ),
                        ),
                        KaiText.micro('апр — май 2026', color: c.ink3),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: KaiSpace.s2),
          const SpecNote('.trip-hero: r16, pad 16; glyph 13px w700 white, r11 = KaiAvatar(size:~36)'),
          const SpecNote('Trip name: 16px w600; sub: 11px ink3'),
          const SpecNote('Stats: .stat .n 16px w600; .stat .l 9px w500 ink3'),
          const SpecNote('Budget bar: r999, bg surface-3, colored segments'),

          const SizedBox(height: KaiSpace.s3),

          // Facts grid demo
          Wrap(
            spacing: KaiSpace.s2,
            runSpacing: KaiSpace.s2,
            children: [
              FactCard(label: 'Виза', value: 'Нет', c: c),
              FactCard(label: 'Дней', value: '12', c: c),
              FactCard(label: 'Бюджет', value: '120k ₽', c: c),
            ],
          ),
          const SizedBox(height: KaiSpace.s2),
          const SpecNote('.fact: bg surface-2, r12, pad 4; .fact .k 11px ink3; .fact .v 11.5px w500 ink1'),

          const SizedBox(height: KaiSpace.s3),

          // Chat item demo
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: c.accentWash,
              borderRadius: KaiRadius.br2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Визовые требования',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: c.accent,
                  ),
                ),
                const SizedBox(height: 2),
                KaiText.micro('Для туристической визы нужен...', color: c.ink3),
              ],
            ),
          ),
          const SizedBox(height: KaiSpace.s2),
          const SpecNote('.chat-item: r10, pad 9/10, bg accent-wash; title 12px w600 accent; preview 10.5px ink3'),

          const SizedBox(height: KaiSpace.s3),
          const SpecNote('"Ask about this" button: 13px w600 white bg ink1 r12 pad11 = KaiButton.ink(fullWidth:true)'),
          const SpecNote('Q&A chips: bg surface-2, r10, pad 9/6'),
          const SpecNote('App bar ic-btn: circle bg surface-2 ~32×32; title 13px w600 ink1'),
          const SizedBox(height: KaiSpace.s3),
          const SpecNote('Dart components to reuse: KaiAvatar, KaiButton.ink, KaiSourceCard, KaiInput.line'),
          const SpecNote('NEW widgets needed: TripHeroCard, TripFactGrid, TripBudgetBar, TripChatItem'),
        ],
      ),
    );
  }
}

class FactCard extends StatelessWidget {
  const FactCard({
    super.key,
    required this.label,
    required this.value,
    required this.c,
  });
  final String label;
  final String value;
  final KaiColorTokens c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: KaiRadius.br12,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                color: c.ink3,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: c.ink1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fork Card spec-preview.
class ForkCardCanonPreview extends StatelessWidget {
  const ForkCardCanonPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;

    return SpecSection(
      title: 'KaiForkCard — spec values (NOT YET BUILT)',
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
              'NOT YET BUILT — canon: new-design/fork.html  .fc',
              color: c.warning,
            ),
          ),
          const SizedBox(height: KaiSpace.s4),

          // Two-column demo skeleton
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ForkColumn(
                  country: 'Япония',
                  price: '145,000 ₽',
                  delta: '+12%',
                  positive: false,
                  c: c,
                ),
              ),
              const SizedBox(width: KaiSpace.s3),
              Expanded(
                child: ForkColumn(
                  country: 'Таиланд',
                  price: '89,000 ₽',
                  delta: '-8%',
                  positive: true,
                  c: c,
                  winner: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: KaiSpace.s3),

          const SpecNote('CSS: .fc, .fc-h, .fc-cols, .fc-col, .fc-id, .fc-country'),
          const SpecNote('.fc-country header: ~65px wide'),
          const SpecNote('Visa chips: 8px w600, r999, pad 2/6, negative-wash/neutral'),
          const SpecNote('Rating dots: 5×5px circles, positive/neutral/negative colors'),
          const SpecNote('.fc-badge, .fc-sw, .fc-score (5-dot rating)'),
          const SizedBox(height: KaiSpace.s3),

          // Visa chip demo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: c.negativeWash,
                  borderRadius: KaiRadius.brPill,
                ),
                child: Text(
                  'VISA',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: c.negative,
                  ),
                ),
              ),
              const SizedBox(width: KaiSpace.s2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: c.surface2,
                  borderRadius: KaiRadius.brPill,
                  border: Border.all(color: c.line),
                ),
                child: Text(
                  'БЕЗВИЗ',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: c.ink2,
                  ),
                ),
              ),
              const SizedBox(width: KaiSpace.s4),
              // Rating dots
              Row(
                children: [
                  RatingDot(color: c.positive),
                  const SizedBox(width: 3),
                  RatingDot(color: c.positive),
                  const SizedBox(width: 3),
                  RatingDot(color: c.positive),
                  const SizedBox(width: 3),
                  RatingDot(color: c.warning),
                  const SizedBox(width: 3),
                  RatingDot(color: c.line),
                ],
              ),
              const SizedBox(width: KaiSpace.s2),
              KaiText.micro('рейтинг 4/5', color: c.ink3),
            ],
          ),
          const SizedBox(height: KaiSpace.s3),
          const SpecNote('Dart to reuse: KaiSourceCard layout pattern, KaiText, KaiTide.gradientCorner'),
          const SpecNote('NEW: KaiForkCard, ForkColumn, ForkVisaChip, ForkRatingDots'),
        ],
      ),
    );
  }
}

class ForkColumn extends StatelessWidget {
  const ForkColumn({
    super.key,
    required this.country,
    required this.price,
    required this.delta,
    required this.positive,
    required this.c,
    this.winner = false,
  });
  final String country;
  final String price;
  final String delta;
  final bool positive;
  final KaiColorTokens c;
  final bool winner;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KaiSpace.s3),
      decoration: BoxDecoration(
        color: winner ? c.accentWash : c.surface2,
        borderRadius: KaiRadius.br3,
        border: winner ? Border.all(color: c.accentLine) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            country,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c.ink1,
            ),
          ),
          const SizedBox(height: KaiSpace.s2),
          Text(
            price,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: winner ? c.accent : c.ink1,
            ),
          ),
          Text(
            delta,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11,
              color: positive ? c.positive : c.negative,
            ),
          ),
        ],
      ),
    );
  }
}

class RatingDot extends StatelessWidget {
  const RatingDot({super.key, required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: color,
        borderRadius: KaiRadius.brPill,
      ),
    );
  }
}
