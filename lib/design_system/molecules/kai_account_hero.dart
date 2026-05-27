import 'package:flutter/material.dart';

import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// Account hero card for settings + nav account anchor.
/// Canon: `new-design/settings.html § .acc-hero`.
///
/// ```
/// container: surface-2 bg, radius 12, padding 12, flex row gap 10
/// avatar: 36 x 36 circle, tide-gradient bg, color white, font 700/13 sans
/// name: Manrope 600/13, ink-1, letter-spacing -0.01em
/// email: JetBrains Mono 400/10, ink-3, mt 1
/// plan badge: mono 500/9 uppercase, accent on accent-wash, padding 2 x 6,
///             radius 999, 1px accent-line border, letter-spacing 0.06em
/// ```
///
/// The avatar uses the main tide gradient (115°), not gradientCorner —
/// canon brand.html avatar circles + settings.html acc-hero both use 115°.
class KaiAccountHero extends StatelessWidget {
  const KaiAccountHero({
    required this.name,
    required this.email,
    required this.initial,
    this.planLabel,
    super.key,
  });

  final String name;
  final String email;

  /// Single letter (or short string) shown inside the avatar circle.
  final String initial;

  /// Optional badge text — "plus", "free", "pro", etc. Renders as accent pill
  /// on the right. Null hides the badge entirely.
  final String? planLabel;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar — tide gradient circle, white centred initial.
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              gradient: KaiTide.gradient,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFFFFFF),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Name + email column
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.ink1,
                    letterSpacing: -0.01 * 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  email,
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: c.ink3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (planLabel != null) ...[
            const SizedBox(width: 10),
            _PlanBadge(label: planLabel!),
          ],
        ],
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  const _PlanBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.accentWash,
        border: Border.all(color: c.accentLine, width: 1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: c.accent,
          letterSpacing: 0.06 * 9,
        ),
      ),
    );
  }
}
