import 'package:flutter/material.dart';

import '../atoms/kai_icon.dart';
import '../atoms/kai_text.dart';
import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// A single hotline / care resource displayed inside [CareBlock].
class CareResource {
  const CareResource({required this.label, required this.number});

  /// Human-readable label (e.g. "Телефон доверия кризисной помощи").
  final String label;

  /// Phone number / shortcode. Rendered in mono.
  final String number;
}

/// Crisis C3 in-conversation pattern.
///
/// Source: `new-design/edge-states.html § 04 Crisis · C3 in-conversation`.
///
/// Critical rules:
/// - Coral negative (`#C44A3C`) — never bright red.
/// - Inline inside chat — never a takeover screen.
/// - User keeps full agency; compose stays visible above this block.
///
/// Layout:
///
///   ❤ Heading
///   Body copy explaining the offered support.
///   988  ·  Lifeline
///   741741  ·  Crisis Text Line
///   Closing italic.
class CareBlock extends StatelessWidget {
  const CareBlock({
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
  final List<CareResource>? resources;

  /// Optional italic closing line.
  final String? closing;

  /// Optional tap callback for a single resource. Receives the tapped one
  /// — callers route to dial / link / share. No side-effects fire here.
  final ValueChanged<CareResource>? onResourceTap;

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
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(KaiRadius.r2),
          bottomRight: Radius.circular(KaiRadius.r2),
        ),
      ),
      child: Padding(
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

class _ResourceRow extends StatelessWidget {
  const _ResourceRow({
    required this.resource,
    required this.color,
    this.onTap,
  });

  final CareResource resource;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        // Canon: care-block resource numbers are Manrope 600/14, NOT mono.
        // Mono renders wider + cooler; care-block must stay warm + warm/dense
        // (CLAUDE.md: "Crisis stays warm, never alarming").
        Text(
          resource.number,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
            letterSpacing: -0.005 * 14,
          ),
        ),
        const SizedBox(width: KaiSpace.s2),
        Text(
          '· ${resource.label}',
          style: KaiType.small(color: color),
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
