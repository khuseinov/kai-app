import 'package:flutter/material.dart';

import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';
import '../atoms/atoms.dart';
import '../primitives/primitives.dart';

/// v3 Kai (AI) message bubble — left-aligned, no background.
///
/// Canon: `new-design/components.html § .bub.kai`
///
/// ## Design notes
///
/// ### Layer compliance
/// This molecule accepts `List<Widget> sources` so it never imports `SourceCard`
/// (a molecule). The caller composes and passes source widgets. This is the fix
/// for the v2 atom→molecule layer-inversion bug.
///
/// ### Font size
/// Body is **13.5px** (D2 locked: room.html is the real chat context — canon —
/// not components.html's 15px catalog display). The `.who` label is **9px**.
/// `KaiType.small` (14) / `KaiType.mono` (12) are the nearest tokens, adjusted
/// via `.copyWith(fontSize:)`.
///
/// ### Citation parsing
/// Inline citations `[1]`, `[2]` etc. are parsed by [_parseCitations] into a
/// `List<TextSpan>` using the regex `\[\d+\]`. Citation spans are rendered in
/// `colors.accent` with `FontWeight.w500` (per canon `.cite` class). This is
/// presentational formatting — no business logic.
///
/// ### Streaming caret
/// When [streaming] is true, a blinking 7×14 ink1 block is appended after the
/// text. Canon `@keyframes cursor { 50% { opacity: 0; } }` at 1s steps(1). We
/// approximate this with `AnimatedOpacity` toggling 0↔1 every 500ms (1s period).
///
/// ### React buttons
/// `onThumbUp` / `onThumbDown` callbacks gate the react row — omitted when both
/// are null. Uses `KaiIconButton.bare` with `KaiIconName.thumbUp/thumbDown`.
/// Icon size 11 matches canon `<svg width="11" height="11">`.
///
/// ### "who" glyph
/// `KaiGradientBar(width: 16, height: 4)` per canon `.who::before {width:16px; height:4px}`.
///
/// ### "who" label mono size
/// 9px JetBrains Mono uppercase (D2 locked, room.html). `KaiType.mono` is 12px;
/// applied as `.copyWith(fontSize: 9)` to keep the JetBrains family.
///
/// API:
/// ```dart
/// KaiKaiBubble(
///   text: 'Тут ваш ответ [1].',
///   sourcesLabel: '2 источника · только что проверено',
///   sources: [SourceCard(...)],
///   streaming: false,
///   onThumbUp: () {},
///   onThumbDown: () {},
/// )
/// ```
class KaiKaiBubble extends StatefulWidget {
  const KaiKaiBubble({
    required this.text,
    this.sourcesLabel,
    this.sources = const [],
    this.streaming = false,
    this.onThumbUp,
    this.onThumbDown,
    super.key,
  });

  /// Message body text. May contain inline citations like `[1]`, `[2]`.
  final String text;

  /// Optional meta label, e.g. "2 источника · только что проверено".
  /// When provided, a meta-row is shown below the body text.
  final String? sourcesLabel;

  /// Source widgets rendered below the meta-row. Pass pre-built `SourceCard`
  /// (or any Widget) — this molecule does NOT import SourceCard.
  final List<Widget> sources;

  /// When `true`, appends a blinking 7×14 caret after the last text character.
  /// Canon: `animation: cursor 1s steps(1) infinite; 50% { opacity: 0 }`.
  final bool streaming;

  /// Callback for thumb-up reaction. Omit to hide the react button.
  final VoidCallback? onThumbUp;

  /// Callback for thumb-down reaction. Omit to hide the react button.
  final VoidCallback? onThumbDown;

  @override
  State<KaiKaiBubble> createState() => _KaiKaiBubbleState();
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class _KaiKaiBubbleState extends State<KaiKaiBubble>
    with SingleTickerProviderStateMixin {
  // Caret blink: AnimationController driving 0↔1 every 500ms (1s full cycle).
  AnimationController? _caretController;

  @override
  void initState() {
    super.initState();
    if (widget.streaming) {
      _startCaret();
    }
  }

  @override
  void didUpdateWidget(KaiKaiBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.streaming && _caretController == null) {
      _startCaret();
    } else if (!widget.streaming && _caretController != null) {
      _caretController!.dispose();
      _caretController = null;
    }
  }

  void _startCaret() {
    _caretController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // half-period; total 1s
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _caretController?.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final c = tokens.colors;

    final hasReact = widget.onThumbUp != null || widget.onThumbDown != null;
    final hasMetaRow = widget.sourcesLabel != null || hasReact;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── .who row ────────────────────────────────────────────────────────
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Canon: .who::before — 16×4 tide-gradient pill
            const KaiGradientBar(width: 16, height: 4),
            const SizedBox(width: 8), // canon: gap 8px
            Text(
              'KAI',
              style: KaiType.mono(color: c.ink3).copyWith(
                // canon (D2 locked): 9px — room.html .who (components shows 10).
                fontSize: 9, // canon: 9 (room / D2)
                letterSpacing: 9 * 0.08, // canon: 0.08em
              ),
            ),
          ],
        ),

        // Gap between .who and .txt — canon: flex gap 6px
        const SizedBox(height: 6),

        // ── .txt — body with inline citation parsing ────────────────────────
        _buildBodyText(c),

        // ── meta-row (sources label + optional react) ───────────────────────
        if (hasMetaRow) ...[
          const SizedBox(height: 4), // canon: margin-top 4px
          _buildMetaRow(c, hasReact),
        ],

        // ── source widgets ──────────────────────────────────────────────────
        if (widget.sources.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...widget.sources,
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Body text with citation spans + optional streaming caret
  // ---------------------------------------------------------------------------

  Widget _buildBodyText(KaiColorTokens c) {
    final baseStyle = KaiType.small(color: c.ink1).copyWith(
      // canon (D2 locked): 13.5px — room.html chat context, not components 15px.
      fontSize: 13.5, // canon: 13.5 (room / D2)
      height: 1.55, // canon: line-height 1.55
      letterSpacing: 13.5 * -0.005, // canon: letter-spacing -0.005em
    );

    final citationStyle = baseStyle.copyWith(
      color: c.accent,
      fontWeight: FontWeight.w500, // canon: .cite { font-weight: 500 }
    );

    final spans = _parseCitations(widget.text, baseStyle, citationStyle);

    if (widget.streaming && _caretController != null) {
      // Append blinking caret as a WidgetSpan
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.bottom,
          child: AnimatedBuilder(
            animation: _caretController!,
            builder: (context, _) {
              // steps(1) at 50% → opacity toggles at the midpoint
              final visible = _caretController!.value < 0.5;
              return Opacity(
                opacity: visible ? 1.0 : 0.0,
                child: Container(
                  width: 7, // canon: 7px
                  height: 14, // canon: 14px
                  margin: const EdgeInsets.only(left: 2), // canon: margin-left 2px
                  color: KaiTheme.of(context).colors.ink1,
                ),
              );
            },
          ),
        ),
      );
    }

    return Text.rich(TextSpan(children: spans, style: baseStyle));
  }

  // ---------------------------------------------------------------------------
  // Meta-row (sources label + react buttons)
  // ---------------------------------------------------------------------------

  Widget _buildMetaRow(KaiColorTokens c, bool hasReact) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.sourcesLabel != null)
          Flexible(
            child: Text(
              widget.sourcesLabel!,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: KaiType.mono(color: c.ink3).copyWith(
                // canon: meta-row font-size 11px
                // KaiType.mono base is 12px — drift -1px.
                fontSize: 11, // canon: 11
              ),
            ),
          ),
        if (widget.sourcesLabel != null && hasReact)
          const SizedBox(width: 16), // canon: meta-row gap 16px
        if (hasReact) _buildReactRow(c),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // React row (thumb-up / thumb-down)
  // ---------------------------------------------------------------------------

  Widget _buildReactRow(KaiColorTokens c) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.onThumbUp != null) ...[
          KaiIconButton.bare(
            onPressed: widget.onThumbUp,
            icon: KaiIconName.thumbUp,
            color: c.ink3,
            size: 11, // canon: <svg width="11" height="11">
          ),
          const SizedBox(width: 6), // canon: react gap 6px
        ],
        if (widget.onThumbDown != null)
          KaiIconButton.bare(
            onPressed: widget.onThumbDown,
            icon: KaiIconName.thumbDown,
            color: c.ink3,
            size: 11, // canon: <svg width="11" height="11">
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Citation parser — pure function, no side effects
// ---------------------------------------------------------------------------

/// Parses [text] for citation patterns `[N]` (one or more digits inside brackets)
/// and returns a list of [TextSpan]s where citations are rendered in [citationStyle]
/// and surrounding text in [baseStyle].
List<InlineSpan> _parseCitations(
  String text,
  TextStyle baseStyle,
  TextStyle citationStyle,
) {
  final pattern = RegExp(r'\[\d+\]');
  final spans = <InlineSpan>[];
  var cursor = 0;

  for (final match in pattern.allMatches(text)) {
    if (match.start > cursor) {
      spans.add(TextSpan(
        text: text.substring(cursor, match.start),
        style: baseStyle,
      ));
    }
    spans.add(TextSpan(
      text: match.group(0),
      style: citationStyle,
    ));
    cursor = match.end;
  }

  if (cursor < text.length) {
    spans.add(TextSpan(
      text: text.substring(cursor),
      style: baseStyle,
    ));
  }

  // Fallback: if no matches, return a single base span
  if (spans.isEmpty) {
    spans.add(TextSpan(text: text, style: baseStyle));
  }

  return spans;
}
