import 'package:flutter/material.dart';

import '../primitives/kai_gradient_bar.dart';

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

  /// Human-readable timestamp displayed above the event (e.g. "9:41").
  final String timestamp;
}

// ── Widget ────────────────────────────────────────────────────────────────────

/// Voice-mode transcript timeline molecule.
///
/// Renders a dark vertical timeline of [KaiTranscriptEvent]s. Each event
/// shows a timestamp and speech text. Kai events additionally display the
/// tide who-glyph (`KaiGradientBar(width: 16, height: 4)`) above the text.
///
/// **Dark-surface only.** This widget is designed to sit on the always-dark
/// voice field (#08080A). All colours are fixed white/tide literals —
/// NOT theme tokens — and will not adapt to light mode.
///
/// Canon `.tr-view` / `.tr-event`:
/// - Event padding: `EdgeInsets.fromLTRB(52, 9, 22, 9)` — left 52px provides
///   gutter for a future rail / glyph; right 22px. (Canon literals.)
/// - Timestamp (`.ts`): 8.5px / w500, `Color(0x66FFFFFF)` (white @ ~0.4).
/// - Body text: full white `Color(0xFFFFFFFF)`.
class KaiTranscriptView extends StatelessWidget {
  const KaiTranscriptView({
    required this.events,
    super.key,
  });

  /// Ordered list of transcript events to display.
  final List<KaiTranscriptEvent> events;

  // ── Fixed dark-surface colours (literals, NOT theme tokens) ─────────────────
  // Event body text: full white.
  static const Color _textColor = Color(0xFFFFFFFF);
  // Timestamp: white at ~40% opacity.
  // Canon: rgba(white, 0.4) → alpha = round(0.4 * 255) = 102 = 0x66.
  static const Color _timestampColor = Color(0x66FFFFFF);

  // ── Canon layout literals ────────────────────────────────────────────────────
  // Canon .tr-event: padding left 52 / top 9 / right 22 / bottom 9.
  // Left 52px reserves the gutter for the glyph/rail column.
  static const EdgeInsets _eventPadding =
      EdgeInsets.fromLTRB(52, 9, 22, 9);
  // Timestamp: 8.5px / w500 Manrope.
  static const double _tsFontSize = 8.5;
  static const FontWeight _tsFontWeight = FontWeight.w500;
  static const String _fontFamily = 'Manrope';
  // Body text: 13px / w400 Manrope (standard voice transcript size).
  static const double _bodyFontSize = 13;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final event in events) _buildEvent(event),
      ],
    );
  }

  Widget _buildEvent(KaiTranscriptEvent event) {
    final isKai = event.who == 'kai';

    return Padding(
      padding: _eventPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Kai events show the tide who-glyph before the timestamp row.
          if (isKai) ...[
            const KaiGradientBar(width: 16, height: 4),
            const SizedBox(height: 4),
          ],
          // Timestamp row.
          Text(
            event.timestamp,
            style: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: _tsFontSize,
              fontWeight: _tsFontWeight,
              color: _timestampColor,
            ),
          ),
          const SizedBox(height: 3),
          // Body text.
          Text(
            event.text,
            style: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: _bodyFontSize,
              fontWeight: FontWeight.w400,
              color: _textColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
