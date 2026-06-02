import 'package:flutter/material.dart';

import '../../../../design_system/theme/kai_theme.dart';
import '../../../../design_system/tokens/kai_tokens.dart';
import '../../../../design_system/atoms/atoms.dart';
import '../../../../design_system/primitives/primitives.dart';

/// A single hotline / care resource displayed inside [KaiCareBlock].
class KaiCareResource {
  const KaiCareResource({required this.label, required this.number});

  /// Human-readable label (e.g. "Телефон доверия кризисной помощи").
  final String label;

  /// Phone number / shortcode. Rendered in Manrope 600 warm (NOT mono).
  final String number;
}

/// Crisis C3 in-conversation pattern — v3 port of v2 `CareBlock`.
///
/// Source: `new-design/edge-states.html § 04 Crisis · C3 in-conversation`.
///
/// Critical rules:
/// - Coral negative (`#C44A3C`) — never bright red.
/// - Inline inside chat — never a takeover screen.
/// - User keeps full agency; compose stays visible above this block.
///
/// Layout:
/// ```
///   ❤ Heading
///   Body copy explaining the offered support.
///   988  ·  Lifeline
///   741741  ·  Crisis Text Line
///   Closing italic.
/// ```
///
/// Border: `left` 2px in `colors.negative` (coral), right corners r2 (10px),
/// left corners flush (r0). Interior padding is 14px on all sides — this is a
/// canon literal from the HTML spec; 14 falls between s3 (12) and s4 (16).
/// Documented here as: `// canon: 14px interior padding (between s3/s4)`.
class KaiCareBlock extends StatelessWidget {
  const KaiCareBlock({
    required this.heading,
    required this.body,
    this.resources,
    this.closing,
    this.onResourceTap,
    super.key,
  });

  /// Section heading (e.g. "Я слышу тебя.").
  final String heading;

  /// Body copy.
  final String body;

  /// Optional resource list (hotlines, text lines).
  final List<KaiCareResource>? resources;

  /// Optional italic closing line.
  final String? closing;

  /// Optional tap callback for a single resource. Receives the tapped one —
  /// callers route to dial / link / share. No side-effects fire here.
  final ValueChanged<KaiCareResource>? onResourceTap;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final negative = c.negative;
    // 4% wash over surface — keeps inline texture without screaming.
    final bg = negative.withValues(alpha: 0.04);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          left: BorderSide(color: negative, width: 2),
        ),
        // Canon: left corners flush (r0), right corners r2 (10px).
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(KaiRadius.r2),
          bottomRight: Radius.circular(KaiRadius.r2),
        ),
      ),
      child: Padding(
        // canon: 14px interior padding (between s3=12 and s4=16)
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                KaiIcon(KaiIconName.heart, size: 18, color: negative),
                const SizedBox(width: KaiSpace.s2),
                Expanded(child: KaiText.h3(heading)),
              ],
            ),
            const SizedBox(height: KaiSpace.s2),
            KaiText.body(body, color: c.ink2),
            if (resources != null && resources!.isNotEmpty) ...[
              const SizedBox(height: KaiSpace.s3),
              ..._buildResources(c),
            ],
            if (closing != null) ...[
              const SizedBox(height: KaiSpace.s3),
              Text(
                closing!,
                style: KaiType.small(color: c.ink3).copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildResources(KaiColorTokens c) {
    final out = <Widget>[];
    for (var i = 0; i < resources!.length; i++) {
      final r = resources![i];
      out.add(
        _ResourceRow(
          resource: r,
          color: c.negative,
          onTap: onResourceTap == null ? null : () => onResourceTap!(r),
        ),
      );
      if (i < resources!.length - 1) {
        out.add(const SizedBox(height: KaiSpace.s1));
      }
    }
    return out;
  }
}

// ---------------------------------------------------------------------------
// _ResourceRow
// ---------------------------------------------------------------------------

class _ResourceRow extends StatelessWidget {
  const _ResourceRow({
    required this.resource,
    required this.color,
    this.onTap,
  });

  final KaiCareResource resource;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        // Canon: care-block resource numbers are Manrope 600/14, NOT mono.
        // Mono renders wider + cooler; care-block must stay warm + dense
        // (CLAUDE.md: "Crisis stays warm, never alarming").
        Text(
          resource.number,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
            // canon: -0.005em letter-spacing on 14px
            letterSpacing: -0.005 * 14,
          ),
        ),
        const SizedBox(width: KaiSpace.s2),
        Flexible(
          child: Text(
            '· ${resource.label}',
            overflow: TextOverflow.ellipsis,
            style: KaiType.small(color: color),
          ),
        ),
      ],
    );
    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      child: row,
    );
  }
}
