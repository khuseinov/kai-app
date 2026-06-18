import 'package:flutter/material.dart';
import 'package:kai_app/design_system/atoms/kai_avatar.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

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
    final scale = context.scale;
    final isCompact = variant == KaiAccountHeroVariant.compact;

    final content = Container(
      padding: EdgeInsets.all(KaiSpace.s3 * scale), // scaled 12px
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: KaiRadius.br12,
      ),
      child: isCompact ? _buildCompact(context, c, scale) : _buildFull(context, c, scale),
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

  Widget _buildFull(BuildContext context, KaiColorTokens c, double scale) {
    final textScale = context.textScale;
    return Row(
      children: [
        KaiAvatar(size: _avatarSize * scale, initial: initial),
        SizedBox(width: 10 * scale), // canon: gap 10
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13 * textScale,
                  fontWeight: FontWeight.w600,
                  color: c.ink1,
                  letterSpacing: -0.01 * 13 * textScale,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 1 * scale),
              Text(
                email,
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 10 * textScale,
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
          SizedBox(width: 10 * scale),
          _PlanBadge(label: planLabel!, scale: scale),
        ],
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Compact layout: avatar (sm) + name only, single row
  // -------------------------------------------------------------------------

  Widget _buildCompact(BuildContext context, KaiColorTokens c, double scale) {
    final textScale = context.textScale;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        KaiAvatar.user(initial, avatarSize: KaiAvatarSize.sm),
        SizedBox(width: 8 * scale),
        Flexible(
          child: Text(
            name,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13 * textScale,
              fontWeight: FontWeight.w600,
              color: c.ink1,
              letterSpacing: -0.01 * 13 * textScale,
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
  const _PlanBadge({required this.label, required this.scale});

  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final textScale = context.textScale;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 2 * scale),
      decoration: BoxDecoration(
        color: c.accentWash,
        border: Border.all(color: c.accentLine),
        borderRadius: KaiRadius.brPill,
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 9 * textScale,
          fontWeight: FontWeight.w500,
          color: c.accent,
          letterSpacing: 0.06 * 9 * textScale,
        ),
      ),
    );
  }
}



