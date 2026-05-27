import 'package:flutter/material.dart';

import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// HTML canon: `new-design/room.html § .kai-b .src-card`
/// bg surface-2, radius 10, padding 8×10, column gap 3px
///
/// Layout:
///   .h — Row(Favicon 10×10 r3 tide-2 + url 9px mono ink3 + ok 9px mono positive)
///   .t — 11.5px w500 ink1 (title)
///   .s — 10px ink3 height 1.4 (snippet)
///   .expand-hint — 9px mono accent uppercase (optional)
class SourceCard extends StatelessWidget {
  const SourceCard({
    required this.url,
    required this.title,
    this.snippet,
    this.fresh = false,
    this.expandHint,
    super.key,
  });

  /// Cited URL or host shown in the header row.
  final String url;

  /// Title of the source (`.t` row).
  final String title;

  /// Optional snippet text (`.s` row). Null = row hidden.
  final String? snippet;

  /// Whether to show the "✓ fresh" ok-badge. Default false.
  final bool fresh;

  /// Optional tap-to-expand hint (`.expand-hint` row). Null = row hidden.
  final String? expandHint;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;

    return Container(
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // .h row — favicon + url + optional ok badge
          Row(
            children: [
              // favicon placeholder — tide-2 coloured box
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: KaiTide.stop2,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: c.ink3,
                    height: 1.4,
                  ),
                ),
              ),
              if (fresh) ...[
                const SizedBox(width: 4),
                Text(
                  '✓ fresh',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: c.positive,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 3),
          // .t — title
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: c.ink1,
            ),
          ),
          if (snippet != null) ...[
            const SizedBox(height: 3),
            // .s — snippet
            Text(
              snippet!,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: c.ink3,
                height: 1.4,
              ),
            ),
          ],
          if (expandHint != null) ...[
            const SizedBox(height: 3),
            // .expand-hint
            Text(
              expandHint!.toUpperCase(),
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 9,
                fontWeight: FontWeight.w400,
                color: c.accent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
