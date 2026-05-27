import 'package:flutter/material.dart';

import '../atoms/kai_icon.dart';
import '../atoms/kai_text.dart';
import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// Freshness signal for a cited source.
///
/// Source: `new-design/components.html § src-mini` — fresh = silent positive;
/// stale = warning glyph; unknown = no glyph (uses ink-3).
enum SourceFreshness { fresh, stale, unknown }

/// Single citation row for the tool-transparency receipt.
///
/// Layout:
///
///   [ idx ]   url.mono                       12:34   ⚠
///
/// The card itself has no chrome — callers (e.g. a sources sheet) wrap it.
class SourceCard extends StatelessWidget {
  const SourceCard({
    required this.index,
    required this.url,
    this.timestamp,
    this.freshness = SourceFreshness.fresh,
    super.key,
  });

  /// Citation number (1-based). Rendered as `[N]` in a small mono badge.
  final int index;

  /// Cited URL or host. Rendered in [KaiText.mono] with ellipsis on overflow.
  final String url;

  /// Optional timestamp string (e.g. "12:34" or "5d"). Renders in small ink-3.
  final String? timestamp;

  /// Freshness state. Stale paints the alert glyph in [KaiColorTokens.warning].
  final SourceFreshness freshness;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KaiSpace.s2,
        vertical: KaiSpace.s2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _IndexBadge(index: index),
          const SizedBox(width: KaiSpace.s2),
          Expanded(
            child: Text(
              url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: KaiType.mono(color: c.ink1),
            ),
          ),
          if (timestamp != null) ...[
            const SizedBox(width: KaiSpace.s2),
            KaiText.small(timestamp!, color: c.ink3),
          ],
          if (freshness == SourceFreshness.stale) ...[
            const SizedBox(width: KaiSpace.s2),
            KaiIcon(KaiIconName.alert, size: 14, color: c.warning),
          ],
        ],
      ),
    );
  }
}

class _IndexBadge extends StatelessWidget {
  const _IndexBadge({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: KaiRadius.br1,
      ),
      child: Text(
        '[$index]',
        style: KaiType.mono(color: c.ink3),
      ),
    );
  }
}
