import 'package:flutter/material.dart';

import '../../theme/kai_theme.dart';
import '../../tokens/kai_tokens.dart';
import '../atoms/atoms.dart';

/// v3 source-citation card — a referenced URL row inside a Kai message.
///
/// Ports v2 `SourceCard` with one addition: an optional [onTap] callback so
/// the card can be made interactive (v2 had `expandHint` but no tap handler).
///
/// Layout (canon: `new-design/components.html .src-list .src-row`):
/// ```
/// ┌──────────────────────────────────────────┐
/// │  [idx]  favicon  url ··············· ✓ fresh │
/// │         Title of the source               │
/// │         Snippet text…                     │
/// └──────────────────────────────────────────┘
/// ```
///
/// - Container: surface-2 bg, r10 radius, 8×10 padding.
/// - Header row: index chip (optional) + favicon placeholder + url (mono,
///   ink3) + freshness badge (mono, positive / ink3).
/// - Title row: Manrope 11.5/w500 ink1.
/// - Snippet row (optional): Manrope 10/w400 ink3.
///
/// The entire card is wrapped in a [GestureDetector] when [onTap] is provided.
class KaiSourceCard extends StatelessWidget {
  const KaiSourceCard({
    required this.url,
    this.title,
    this.snippet,
    this.index,
    this.fresh = false,
    this.onTap,
    super.key,
  });

  /// Cited URL or host shown in the header row.
  final String url;

  /// Title of the source. When null the title row is hidden.
  final String? title;

  /// Optional snippet text. When null the row is hidden.
  final String? snippet;

  /// 1-based numeric index shown as a small mono chip on the left. When null
  /// the index slot is omitted.
  final int? index;

  /// When `true`, shows "✓ fresh" in `positive` color. Default false.
  final bool fresh;

  /// Optional tap callback. When provided the card is wrapped in a
  /// [GestureDetector] so it behaves as a tappable row.
  final VoidCallback? onTap;

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;

    Widget card = Container(
      decoration: BoxDecoration(
        color: c.surface2,
        // canon: components.html .src-row { border-radius: 10px } → r2 = 10
        borderRadius: KaiRadius.br2,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: KaiSpace.s2 + 2, // canon: 10px horizontal
        vertical: KaiSpace.s2, // canon: 8px vertical
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: [index] favicon url [freshness]
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Optional index chip — mono, surface bg, r4 corner.
              if (index != null) ...[
                _IndexChip(index: index!),
                const SizedBox(width: KaiSpace.s1 + 2), // canon: 6px gap
              ],
              // Favicon placeholder — tide-2 mini square, r3.
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: KaiTide.stop2,
                  borderRadius: KaiRadius.br1, // r1 = 6 — closest to canon r3
                ),
              ),
              const SizedBox(width: KaiSpace.s1 + 2), // canon: 6px
              // URL — mono 9px ink3, single line, ellipsis.
              Expanded(
                child: Text(
                  url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 9, // canon: src-row .url font-size 9px
                    fontWeight: FontWeight.w400,
                    color: c.ink3,
                    height: 1.4,
                  ),
                ),
              ),
              // Freshness badge — mono 9px positive / ink3.
              if (fresh) ...[
                const SizedBox(width: KaiSpace.s1),
                Text(
                  '✓ fresh',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 9, // canon: 9px
                    fontWeight: FontWeight.w400,
                    color: c.positive,
                  ),
                ),
              ] else ...[
                const SizedBox(width: KaiSpace.s1),
                Text(
                  '—',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: c.ink3,
                  ),
                ),
              ],
            ],
          ),
          // Title row — shown when title is provided.
          if (title != null) ...[
            const SizedBox(height: 3), // canon: column-gap 3px
            KaiText.small(title!, color: KaiTheme.of(context).colors.ink1),
          ],
          // Snippet row — shown when snippet is provided.
          if (snippet != null) ...[
            const SizedBox(height: 3), // canon: column-gap 3px
            Text(
              snippet!,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 10, // canon: .src-row .s font-size 10px
                fontWeight: FontWeight.w400,
                color: c.ink3,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }

    return card;
  }
}

// ---------------------------------------------------------------------------
// Internal: index chip
// ---------------------------------------------------------------------------

/// Small monospace numeric index displayed to the left of the favicon.
///
/// Canon: `components.html .src-row .idx` — mono, surface bg, ~r4 corner,
/// compact padding. We use `KaiRadius.br1` (6px) which is the closest standard
/// token to the canon 4px; the difference is sub-pixel on a 10–12px chip.
class _IndexChip extends StatelessWidget {
  const _IndexChip({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KaiSpace.s1, // 4px
        vertical: 1, // canon: tight vertical — sub-token literal
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: KaiRadius.br1,
        border: Border.all(color: c.line),
      ),
      child: Text(
        '$index',
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 9, // canon: same scale as url row
          fontWeight: FontWeight.w400,
          color: c.ink3,
          height: 1.0,
        ),
      ),
    );
  }
}
