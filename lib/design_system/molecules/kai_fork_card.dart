import 'package:flutter/material.dart';

import '../atoms/atoms.dart';
import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

// ---------------------------------------------------------------------------
// Data classes
// ---------------------------------------------------------------------------

/// A single comparison row inside a [KaiForkColumn].
class KaiForkRow {
  const KaiForkRow({
    required this.label,
    required this.value,
    this.chipTone,
    this.chipLabel,
    this.score,
  });

  /// Short label for this row (e.g. "виза", "погода").
  final String label;

  /// Value text shown alongside the chip/dots (e.g. "14°C").
  final String value;

  /// When set, a [KaiForkChip] is rendered for this row.
  final KaiForkChipTone? chipTone;

  /// Label for the [KaiForkChip]. Required when [chipTone] is not null.
  final String? chipLabel;

  /// When set, a [KaiForkScoreDots] row is rendered with this score.
  final int? score;
}

/// Data for one column in a [KaiForkCard].
class KaiForkColumn {
  const KaiForkColumn({
    required this.name,
    required this.glyph,
    required this.price,
    required this.rows,
  });

  /// Country name displayed below the glyph (e.g. "Япония").
  final String name;

  /// 2–3 character glyph label shown inside the gradient square (e.g. "JP").
  final String glyph;

  /// Price string (e.g. "\$2,100").
  final String price;

  /// Fact rows — each may carry a chip, score dots, or just text.
  final List<KaiForkRow> rows;
}

// ---------------------------------------------------------------------------
// KaiForkCard
// ---------------------------------------------------------------------------

/// Two-column (or more) comparison molecule rendered inside the chat feed.
///
/// Layout canon: `new-design/fork.html .fc` —
/// - Outer card: `c.surface`, `KaiRadius.br4` (closest to canon 15px → br3=14 vs
///   br4=20; fork.html uses 15px — we use br3 which is 14px, one step below br4).
///   Canon: `border-radius: 15px` → closest token is KaiRadius.r3 = 14px.
/// - 1px `c.line` border.
/// - Header row: small live dot + mono label.
/// - Columns: equal-width side-by-side, 1px `c.line` separator.
/// - Winner / pick column at [pickIndex] (if set): accentWash tint + 2px tide
///   gradient top border + "✓ лучший" accent pill.
class KaiForkCard extends StatelessWidget {
  const KaiForkCard({
    required this.columns,
    this.pickIndex,
    this.headerLabel,
    super.key,
  });

  /// Country columns to compare. Minimum 2.
  /// Minimum 2 columns required at runtime (asserted in [build]).
  final List<KaiForkColumn> columns;

  /// Index into [columns] that is Kai's pick. When set the column gets accent
  /// highlighting and a "✓ лучший" badge. When null no column is highlighted.
  final int? pickIndex;

  /// Optional header label (e.g. "сравниваем · 2 варианта").
  /// Defaults to "${columns.length} варианта".
  final String? headerLabel;

  @override
  Widget build(BuildContext context) {
    assert(columns.length >= 2, 'KaiForkCard requires at least 2 columns');
    final c = KaiTheme.of(context).colors;
    final label = headerLabel ??
        '${columns.length} ${columns.length == 2 ? 'варианта' : 'вариантов'}';

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        // canon: fork.html .fc border-radius 15px → br3 (14px) is the closest
        // standard token to the exact 15px spec.
        borderRadius: KaiRadius.br3,
        border: Border.all(color: c.line, width: 1),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          _ForkHeader(label: label, colors: c),
          // ── Columns ─────────────────────────────────────────────────────
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < columns.length; i++) ...[
                  if (i > 0)
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: c.line,
                    ),
                  Expanded(
                    child: _ForkColumn(
                      column: columns[i],
                      isPick: pickIndex == i,
                      colors: c,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal: header row
// ---------------------------------------------------------------------------

class _ForkHeader extends StatelessWidget {
  const _ForkHeader({required this.label, required this.colors});

  final String label;
  final KaiColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Container(
      // canon: fc-h padding 7px vertical / 11px horizontal
      padding: const EdgeInsets.symmetric(
        horizontal: 11, // canon literal
        vertical: 7, // canon literal
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.line, width: 1)),
      ),
      child: Row(
        children: [
          // Live dot — 5px positive circle
          Container(
            width: 5, // canon: .ldot 5x5
            height: 5,
            decoration: BoxDecoration(
              color: c.positive,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7), // canon: fc-h gap 7px
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 8.5, // canon: .fc-h .lbl 8.5px/500 mono
                fontWeight: FontWeight.w500,
                color: c.ink3,
                letterSpacing: 8.5 * 0.08,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal: single column
// ---------------------------------------------------------------------------

class _ForkColumn extends StatelessWidget {
  const _ForkColumn({
    required this.column,
    required this.isPick,
    required this.colors,
  });

  final KaiForkColumn column;
  final bool isPick;
  final KaiColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final c = colors;

    return Stack(
      children: [
        // Tinted background for winning column
        if (isPick)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                // canon: .fc-col.win gradient overlay ~7% tide-2
                color: const Color(0xFF2BA8C9).withValues(alpha: 0.07),
              ),
            ),
          ),
        // Top accent bar for winning column
        if (isPick)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 2, // canon: .fc-col.win::before height 2px tide gradient
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: KaiTide.gradient,
              ),
            ),
          ),
        // Column body
        Padding(
          // canon: .fc-col padding 11/11/13
          padding: EdgeInsets.only(
            top: isPick ? 13 : 11, // extra 2px to clear the top accent bar
            left: 11,
            right: 11,
            bottom: 13,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Country id row ─────────────────────────────────────────
              Row(
                children: [
                  _GlyphBadge(glyph: column.glyph),
                  const SizedBox(width: 6), // canon: .fc-country gap 6px
                  Expanded(
                    child: Text(
                      column.name,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11.5, // canon: .fc-name 11.5px/600
                        fontWeight: FontWeight.w600,
                        color: c.ink1,
                        letterSpacing: 11.5 * (-0.01),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Pick badge
                  if (isPick) ...[
                    const SizedBox(width: 4),
                    const _PickBadge(),
                  ],
                ],
              ),
              const SizedBox(height: 9), // canon: .fc-col gap 9px
              // ── Price ──────────────────────────────────────────────────
              Text(
                column.price,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 19, // canon: .fc-price 19px/600
                  fontWeight: FontWeight.w600,
                  color: c.ink1,
                  letterSpacing: 19 * (-0.025),
                  height: 1.0,
                ),
              ),
              // ── Fact rows ──────────────────────────────────────────────
              if (column.rows.isNotEmpty) ...[
                const SizedBox(height: 9),
                ...column.rows.map(
                  (row) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _ForkRow(row: row, colors: c),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Internal: glyph badge — 18×18 gradient rounded square with 2-3 char label
// ---------------------------------------------------------------------------

class _GlyphBadge extends StatelessWidget {
  const _GlyphBadge({required this.glyph});

  final String glyph;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18, // canon: .fc-glyph 18×18
      height: 18,
      decoration: const BoxDecoration(
        // canon: .fc-glyph background tide-gradient-corner
        gradient: KaiTide.gradientCorner,
        borderRadius: BorderRadius.all(
          Radius.circular(5), // canon: .fc-glyph border-radius 5px (≈ KaiRadius.r1=6px, literal used)
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        glyph,
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 7, // canon: .fc-glyph font 7px/700
          fontWeight: FontWeight.w700,
          color: Color(0xFFFFFFFF), // sanctioned white-on-fill
          height: 1.0,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal: pick badge — accent pill "✓ лучший"
// ---------------------------------------------------------------------------

class _PickBadge extends StatelessWidget {
  const _PickBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6, // canon: .fc-badge padding 2/6
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2BA8C9).withValues(alpha: 0.10),
        borderRadius: KaiRadius.brPill,
      ),
      child: const Text(
        '✓ лучший',
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 7.5, // canon: .fc-badge 7.5px/600 mono
          fontWeight: FontWeight.w600,
          color: KaiTide.stop2, // canon: color: var(--tide-2) = #2BA8C9
          letterSpacing: 7.5 * 0.05,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal: single fact row — chip + text / score dots
// ---------------------------------------------------------------------------

class _ForkRow extends StatelessWidget {
  const _ForkRow({required this.row, required this.colors});

  final KaiForkRow row;
  final KaiColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final hasChip = row.chipTone != null && row.chipLabel != null;

    return Wrap(
      spacing: 3, // canon: .fc-row gap 3px
      runSpacing: 3,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Chip (visa, weather, crowd status)
        if (hasChip)
          KaiForkChip(row.chipLabel!, tone: row.chipTone!)
        else
          // Plain value text when no chip
          Text(
            row.value,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 10.5,
              fontWeight: FontWeight.w400,
              color: c.ink2,
            ),
          ),
        // Score dots
        if (row.score != null) KaiForkScoreDots(score: row.score!),
      ],
    );
  }
}
