import 'package:flutter/material.dart';
import 'package:kai_app/design_system/atoms/atoms.dart';
import 'package:kai_app/design_system/primitives/primitives.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

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
    this.hideWho = false,
    this.statusSuffix,
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

  /// Suffix next to "KAI" (e.g. "думаю" or "ищу информацию о рейсах").
  final String? statusSuffix;

  /// When `true`, hides the `.who` row entirely.
  final bool hideWho;

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
    with TickerProviderStateMixin {
  // Caret blink: AnimationController driving 0↔1 every 500ms (1s full cycle).
  AnimationController? _caretController;
  AnimationController? _tideBarController;

  @override
  void initState() {
    super.initState();
    if (widget.streaming) {
      _startCaret();
      _startTideBar();
    }
  }

  @override
  void didUpdateWidget(KaiKaiBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.streaming) {
      if (_caretController == null) _startCaret();
      if (_tideBarController == null) _startTideBar();
    } else {
      if (_caretController != null) {
        _caretController!.dispose();
        _caretController = null;
      }
      if (_tideBarController != null) {
        _tideBarController!.dispose();
        _tideBarController = null;
      }
    }
  }

  void _startCaret() {
    _caretController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // half-period; total 1s
    )..repeat(reverse: true);
  }

  void _startTideBar() {
    _tideBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600), // canon: 1.6s
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _caretController?.dispose();
    _tideBarController?.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final c = tokens.colors;
    final scale = context.scale;
    final textScale = context.textScale;

    final hasReact = widget.onThumbUp != null || widget.onThumbDown != null;
    final hasMetaRow = widget.sourcesLabel != null || hasReact;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!widget.hideWho) ...[
          // ── .who row ────────────────────────────────────────────────────────
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.streaming && _tideBarController != null)
                AnimatedBuilder(
                  animation: _tideBarController!,
                  builder: (context, _) {
                    final width = Tween<double>(begin: 10 * scale, end: 22 * scale).animate(
                      CurvedAnimation(
                        parent: _tideBarController!,
                        curve: Curves.easeInOut,
                      ),
                    ).value;
                    return Container(
                      width: width,
                      height: 3 * scale,
                      decoration: const BoxDecoration(
                        gradient: KaiTide.gradient,
                        borderRadius: KaiRadius.brPill,
                      ),
                    );
                  },
                )
              else
                // Canon: .who::before — 16×4 tide-gradient pill
                KaiGradientBar(
                  width: 16 * scale,
                  height: 4 * scale,
                ),
              SizedBox(width: 6 * scale), // canon: gap 6px
              Text(
                'KAI',
                style: KaiType.mono(color: c.ink3).copyWith(
                  // canon (D2 locked): 9px — room.html .who (components shows 10).
                  fontSize: 10 * textScale, // canon: 10 (room / D2)
                  letterSpacing: 10 * textScale * 0.08, // canon: 0.08em
                ),
              ),
              if (widget.streaming && widget.statusSuffix != null) ...[
                SizedBox(width: 6 * scale),
                Text(
                  '· ${widget.statusSuffix}',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10 * textScale,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: c.ink4,
                  ),
                ),
              ],
            ],
          ),

          // Gap between .who and .txt — canon: .kai-b flex gap 5px
          // — verified spec-viewer 2026-05-29 (was 6px)
          if (widget.text.isNotEmpty) SizedBox(height: 5 * scale), // canon: gap 5px
        ],

        // ── .txt — body with inline citation parsing ────────────────────────
        if (widget.text.isNotEmpty) _buildBodyText(context, c, scale),

        // ── meta-row (sources label + optional react) ───────────────────────
        if (hasMetaRow) ...[
          SizedBox(height: 4 * scale), // canon: margin-top 4px
          _buildMetaRow(context, c, scale, hasReact),
        ],

        // ── source widgets ──────────────────────────────────────────────────
        if (widget.sources.isNotEmpty) ...[
          SizedBox(height: 8 * scale),
          ...widget.sources,
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Body text with citation spans + optional streaming caret
  // ---------------------------------------------------------------------------

  Widget _buildBodyText(BuildContext context, KaiColorTokens c, double scale) {
    final textScale = context.textScale;
    final baseStyle = KaiType.small(color: c.ink1).copyWith(
      // canon (D2 locked): 13.5px — room.html chat context, not components 15px.
      fontSize: 15.0 * textScale, // canon: 15.0 (room / D2)
      height: 1.55, // canon: line-height 1.55
      letterSpacing: 15.0 * textScale * -0.005, // canon: letter-spacing -0.005em
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
          child: AnimatedBuilder(
            key: const ValueKey('kai_bubble_caret'),
            animation: _caretController!,
            builder: (context, _) {
              // ponytail: smooth breathing gradient caret to replace harsh blinking block
              final opacity = _caretController!.value;
              return Opacity(
                opacity: opacity,
                child: Container(
                  width: 2.5 * scale,
                  height: 15 * scale,
                  margin: EdgeInsets.only(left: 3 * scale),
                  decoration: BoxDecoration(
                    gradient: KaiTide.gradient,
                    borderRadius: BorderRadius.circular(1.2 * scale),
                  ),
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

  Widget _buildMetaRow(BuildContext context, KaiColorTokens c, double scale, bool hasReact) {
    final textScale = context.textScale;
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
                fontSize: 12 * textScale, // canon: 12
              ),
            ),
          ),
        if (widget.sourcesLabel != null && hasReact)
          SizedBox(width: 16 * scale), // canon: meta-row gap 16px
        if (hasReact) _buildReactRow(context, c, scale),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // React row (thumb-up / thumb-down)
  // ---------------------------------------------------------------------------

  Widget _buildReactRow(BuildContext context, KaiColorTokens c, double scale) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.onThumbUp != null) ...[
          KaiIconButton.bare(
            onPressed: widget.onThumbUp,
            icon: KaiIconName.thumbUp,
            color: c.ink3,
            size: 13 * scale, // canon: <svg width="13" height="13">
          ),
          SizedBox(width: 6 * scale), // canon: react gap 6px
        ],
        if (widget.onThumbDown != null)
          KaiIconButton.bare(
            onPressed: widget.onThumbDown,
            icon: KaiIconName.thumbDown,
            color: c.ink3,
            size: 13 * scale, // canon: <svg width="13" height="13">
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
      ),);
    }
    spans.add(TextSpan(
      text: match.group(0),
      style: citationStyle,
    ),);
    cursor = match.end;
  }

  if (cursor < text.length) {
    spans.add(TextSpan(
      text: text.substring(cursor),
      style: baseStyle,
    ),);
  }

  // Fallback: if no matches, return a single base span
  if (spans.isEmpty) {
    spans.add(TextSpan(text: text, style: baseStyle));
  }

  return spans;
}
