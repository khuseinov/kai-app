import 'package:flutter/material.dart';

import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';
import '../atoms/kai_avatar.dart';

// ---------------------------------------------------------------------------
// Variant enum
// ---------------------------------------------------------------------------

/// Display variant for [KaiAccountHero].
///
/// - [full] — avatar + name + email + optional plan badge. Used on the settings
///   screen header.
/// - [compact] — avatar + name only, single row. Used in the nav panel footer
///   where vertical space is constrained.
enum KaiAccountHeroVariant { full, compact }

// ---------------------------------------------------------------------------
// KaiAccountHero
// ---------------------------------------------------------------------------

/// v3 account hero card for settings + nav account anchor.
/// Canon: `new-design/settings.html § .acc-hero`.
///
/// ```
/// container: surface-2 bg, KaiRadius.br12 (12px), padding 12, flex row gap 10
/// avatar: 36 × 36 circle, tide-gradient (KaiAvatar with size: 36)
/// name: Manrope 600/13, ink-1, letter-spacing -0.01em
/// email: JetBrains Mono 400/10, ink-3, mt 1
/// plan badge: mono 500/9 uppercase, accent on accent-wash, padding 2 × 6,
///             radius 999, 1px accent-line border, letter-spacing 0.06em
/// ```
///
/// **Variants:**
/// - [KaiAccountHeroVariant.full] — current default layout (avatar + name +
///   email + plan badge).
/// - [KaiAccountHeroVariant.compact] — single row with avatar + name only,
///   avatar uses [KaiAvatarSize.sm] (28px) for a tighter fit.
///
/// **onTap** — when provided, wraps the card in an [InkWell].
///
/// Reuses [KaiAvatar] for the gradient circle instead of re-implementing
/// inline. Canon avatar for settings.html uses 36px — pass [size] to KaiAvatar
/// explicitly.
class KaiAccountHero extends StatelessWidget {
  const KaiAccountHero({
    required this.name,
    required this.email,
    required this.initial,
    this.planLabel,
    this.variant = KaiAccountHeroVariant.full,
    this.onTap,
    super.key,
  });

  final String name;
  final String email;

  /// Single letter (or short string) shown inside the avatar circle.
  final String initial;

  /// Optional badge text — "plus", "free", "pro", etc. Rendered as accent pill
  /// on the right (uppercased). Null hides the badge entirely.
  /// Only shown in [KaiAccountHeroVariant.full].
  final String? planLabel;

  /// Display variant. Defaults to [KaiAccountHeroVariant.full].
  final KaiAccountHeroVariant variant;

  /// Optional tap callback. When provided, wraps the widget in an [InkWell]
  /// with [KaiRadius.br12].
  final VoidCallback? onTap;

  // canon: acc-hero avatar diameter is 36px (settings.html)
  static const double _avatarSize = 36;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final isCompact = variant == KaiAccountHeroVariant.compact;

    final content = Container(
      padding: const EdgeInsets.all(KaiSpace.s3), // 12px
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: KaiRadius.br12,
      ),
      child: isCompact ? _buildCompact(c) : _buildFull(c),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: KaiRadius.br12,
        child: content,
      );
    }
    return content;
  }

  // -------------------------------------------------------------------------
  // Full layout: avatar + name column (email + plan badge)
  // -------------------------------------------------------------------------

  Widget _buildFull(KaiColorTokens c) {
    return Row(
      children: [
        KaiAvatar(size: _avatarSize, initial: initial),
        const SizedBox(width: 10), // canon: gap 10
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
    );
  }

  // -------------------------------------------------------------------------
  // Compact layout: avatar (sm) + name only, single row
  // -------------------------------------------------------------------------

  Widget _buildCompact(KaiColorTokens c) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        KaiAvatar.user(initial, avatarSize: KaiAvatarSize.sm),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
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
        ),
      ],
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
        border: Border.all(color: c.accentLine),
        borderRadius: KaiRadius.brPill,
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
