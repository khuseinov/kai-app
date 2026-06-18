import 'package:flutter/material.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

// ── Data model ────────────────────────────────────────────────────────────────

/// A single event in the voice transcript timeline.
///
/// [who] must be `'you'` or `'kai'`.
class KaiTranscriptEvent {
  const KaiTranscriptEvent({
    required this.who,
    required this.text,
    required this.timestamp,
  });

  /// Speaker identifier. Must be `'you'` or `'kai'`.
  final String who;

  /// Transcript text for this event.
  final String text;

  /// Human-readable timestamp displayed in the meta row (e.g. "9:41").
  final String timestamp;
}

// ── Widget ────────────────────────────────────────────────────────────────────

/// Voice-mode transcript timeline molecule.
///
/// Renders a vertical timeline of [KaiTranscriptEvent]s on a 1px rail.
/// Each event carries a 9px rail dot in the left gutter (you = translucent
/// white/grey; **kai = tide-gradient + glow**, the brand mark), a meta row
/// (`who` label + timestamp) and the body text.
///
/// Canon `voice.html .tr-view / .tr-event`:
/// - Event padding `EdgeInsets.fromLTRB(52, 9, 22, 9)`; rail line at x=36
///   (white@0.12); rail dot 9px at x≈32.
/// - Meta row (`.ts`): JetBrains Mono 8.5px/500 UPPERCASE, ls 0.14em — `.who`
///   white@0.55, time white@0.4.
/// - Body: Manrope 12px/400, lh 1.5 — you white@0.6, kai full white.
class KaiTranscriptView extends StatelessWidget {
  const KaiTranscriptView({
    required this.events,
    super.key,
  });

  /// Ordered list of transcript events to display.
  final List<KaiTranscriptEvent> events;

  // ── Fixed dark-surface colours (literals, NOT theme tokens) ─────────────────
  static const Color _white = Color(0xFFFFFFFF); // kai body
  static const Color _youBody = Color(0x99FFFFFF); // you body — white@0.6
  static const Color _whoColor = Color(0x8CFFFFFF); // who label — white@0.55
  static const Color _tsColor = Color(0x66FFFFFF); // timestamp — white@0.4
  static const Color _railColor = Color(0x1FFFFFFF); // rail line — white@0.12
  static const Color _youDot = Color(0x80FFFFFF); // you dot — white@0.5
  static const Color _voiceBg = Color(0xFF08080A); // dot ring — voice field bg
  static const Color _kaiGlow = Color(0x402BA8C9); // tide-2 @ 0.25 glow

  // ── Canon layout literals ────────────────────────────────────────────────────
  static const EdgeInsets _eventPadding = EdgeInsets.fromLTRB(52, 9, 22, 9);
  static const double _railX = 36; // vertical rail line x-offset
  static const double _fontFamilySize = 8.5; // meta row size
  static const String _mono = 'JetBrainsMono';
  static const String _sans = 'Manrope';
  static const double _bodySize = 12;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = KaiTheme.of(context).colors;
    final railColor = isDark ? _railColor : c.line;

    return Stack(
      children: [
        // Vertical rail line behind the events.
        Positioned(
          top: 0,
          bottom: 0,
          left: _railX,
          child: SizedBox(
            width: 1,
            child: ColoredBox(color: railColor),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [for (final e in events) _event(e, context, c, isDark)],
        ),
      ],
    );
  }

  Widget _event(KaiTranscriptEvent e, BuildContext context, KaiColorTokens c, bool isDark) {
    final isKai = e.who == 'kai';
    final whiteColor = isDark ? _white : c.ink1;
    final youBodyColor = isDark ? _youBody : c.ink2;
    final whoColor = isDark ? _whoColor : c.ink3;
    final tsColor = isDark ? _tsColor : c.ink4;

    return Padding(
      padding: _eventPadding,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Rail dot — reaches left into the gutter to sit on the rail line.
          Positioned(left: -20, top: 5, child: _dot(isKai, c, isDark)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Meta row: who label + timestamp.
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(e.who.toUpperCase(), style: _metaStyle(whoColor)),
                  const SizedBox(width: 6),
                  Text(e.timestamp, style: _metaStyle(tsColor)),
                ],
              ),
              const SizedBox(height: 3),
              // Body text — speaker-toned.
              Text(
                e.text,
                style: TextStyle(
                  fontFamily: _sans,
                  fontSize: _bodySize,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  letterSpacing: _bodySize * -0.005,
                  color: isKai ? whiteColor : youBodyColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  TextStyle _metaStyle(Color color) => TextStyle(
        fontFamily: _mono,
        fontSize: _fontFamilySize,
        fontWeight: FontWeight.w500,
        letterSpacing: _fontFamilySize * 0.14, // canon: 0.14em
        color: color,
      );

  Widget _dot(bool isKai, KaiColorTokens c, bool isDark) {
    final youDotColor = isDark ? _youDot : c.lineStrong;
    final voiceBgColor = isDark ? _voiceBg : const Color(0xFFFAFAF9);
    final kaiGlowColor = isDark ? _kaiGlow : const Color(0x202BA8C9);

    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isKai ? null : youDotColor,
        gradient: isKai ? KaiTide.gradientCorner : null,
        border: Border.all(color: voiceBgColor, width: 1.6),
        boxShadow: isKai
            ? [
                BoxShadow(color: kaiGlowColor, spreadRadius: 1),
              ]
            : null,
      ),
    );
  }
}
