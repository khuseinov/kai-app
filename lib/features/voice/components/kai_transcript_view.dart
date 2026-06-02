import 'package:flutter/material.dart';

import '../../../design_system/tokens/kai_tokens.dart';

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
/// Renders a dark vertical timeline of [KaiTranscriptEvent]s on a 1px rail.
/// Each event carries a 9px rail dot in the left gutter (you = translucent
/// white; **kai = tide-gradient + glow**, the brand mark), a meta row
/// (`who` label + timestamp) and the body text.
///
/// **Dark-surface only.** Designed for the always-dark voice field (#08080A).
/// All colours are fixed white/tide literals — NOT theme tokens.
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
    return Stack(
      children: [
        // Vertical rail line behind the events.
        const Positioned(
          top: 0,
          bottom: 0,
          left: _railX,
          child: SizedBox(
            width: 1,
            child: ColoredBox(color: _railColor),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [for (final e in events) _event(e)],
        ),
      ],
    );
  }

  Widget _event(KaiTranscriptEvent e) {
    final isKai = e.who == 'kai';
    return Padding(
      padding: _eventPadding,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Rail dot — reaches left into the gutter to sit on the rail line.
          Positioned(left: -20, top: 5, child: _dot(isKai)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Meta row: who label + timestamp.
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(e.who.toUpperCase(), style: _metaStyle(_whoColor)),
                  const SizedBox(width: 6),
                  Text(e.timestamp, style: _metaStyle(_tsColor)),
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
                  color: isKai ? _white : _youBody,
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

  Widget _dot(bool isKai) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isKai ? null : _youDot,
        gradient: isKai ? KaiTide.gradientCorner : null,
        border: Border.all(color: _voiceBg, width: 1.6),
        boxShadow: isKai
            ? const [
                BoxShadow(color: _kaiGlow, blurRadius: 0, spreadRadius: 1),
              ]
            : null,
      ),
    );
  }
}
