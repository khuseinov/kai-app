import 'package:flutter/material.dart';

import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';
import '../primitives/primitives.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// Visual weight for [KaiButton.tide].
///
/// - [normal] — standard primary action (tide gradient, br3, soft shadow).
/// - [glow] — money-gate / hero emphasis (tide gradient, br2, diffuse glow shadow).
enum KaiButtonEmphasis { normal, glow }

/// Tone drives border + text color for [KaiButton.ghost] and [KaiButton.text].
///
/// Values used per variant:
/// - ghost: neutral | warning | negative
/// - text:  neutral | accent  | negative
enum KaiButtonTone { neutral, accent, warning, negative }

/// Size tier for any [KaiButton] variant.
///
/// Maps to canon tiers:
/// - [sm] — 12.5px/w500, compact padding (toast `.open`, detail `.act`).
/// - [md] — 13.5px/w600, regular padding (new-btn 13.5px/pad11, crisis 14px).
///   Default everywhere; existing call-sites need no changes.
/// - [lg] — 15px/w600, generous padding (hero CTA: onboarding "Start",
///   money-gate).
enum KaiButtonSize { sm, md, lg }

// ---------------------------------------------------------------------------
// KaiButton
// ---------------------------------------------------------------------------

/// v3 keystone button — four named-constructor variants + three size tiers.
///
/// ### Variants
/// - `KaiButton.tide` — primary action (tide gradient). Supports
///   [KaiButtonEmphasis.normal] (br3, soft shadow) and
///   [KaiButtonEmphasis.glow] (br2, diffuse glow — money-gate canon).
///   The tide gradient has a subtle looping flow animation ("tide is alive")
///   that respects the system reduce-motion preference.
/// - `KaiButton.ink` — solid ink-1 secondary. `fullWidth: true` stretches to
///   the drawer "new chat" canon (ink1, br12, full-width).
/// - `KaiButton.ghost` — outline button. `pill: true` → brPill for retry pills.
///   [KaiButtonTone] drives border + text color.
/// - `KaiButton.text` — no fill, no border (toast "Открыть", detail-sheet
///   row actions). [KaiButtonTone] drives text color.
///
/// ### Size tiers ([KaiButtonSize])
/// - [KaiButtonSize.sm]  → font 12.5px/w500, pad 8×12 (icon 16)
/// - [KaiButtonSize.md]  → font 13.5px/w600, pad 12×20 (icon 18)  ← default
/// - [KaiButtonSize.lg]  → font 15px/w600,   pad 16×24 (icon 20)
///
/// ### Common behaviour
/// - `onPressed == null` → disabled: opacity 0.5, no tap.
/// - Press → [AnimatedScale] to 0.97, duration [KaiMotion.micro] (120 ms),
///   curve [KaiMotion.standardCurve].
/// - Icon (when provided): [KaiIcon] left of label, gap [KaiSpace.s2].
class KaiButton extends StatefulWidget {
  // -------------------------------------------------------------------------
  // tide
  // -------------------------------------------------------------------------

  /// Primary action — tide gradient + optional glow emphasis.
  const KaiButton.tide({
    required this.onPressed,
    required this.label,
    this.icon,
    this.emphasis = KaiButtonEmphasis.normal,
    this.size = KaiButtonSize.md,
    super.key,
  })  : _variant = _KaiButtonVariant.tide,
        _fullWidth = false,
        _tone = KaiButtonTone.neutral,
        _pill = false;

  // -------------------------------------------------------------------------
  // ink
  // -------------------------------------------------------------------------

  /// Solid secondary button — ink-1 fill, white text.
  ///
  /// Set `fullWidth: true` to match the drawer "new chat" canon
  /// (ink1, br12, stretches to full width).
  const KaiButton.ink({
    required this.onPressed,
    required this.label,
    this.icon,
    bool fullWidth = false,
    this.size = KaiButtonSize.md,
    super.key,
  })  : _variant = _KaiButtonVariant.ink,
        _fullWidth = fullWidth,
        emphasis = KaiButtonEmphasis.normal,
        _tone = KaiButtonTone.neutral,
        _pill = false;

  // -------------------------------------------------------------------------
  // ghost
  // -------------------------------------------------------------------------

  /// Outline button — transparent fill, 1px border.
  ///
  /// - `pill: true` → [KaiRadius.brPill] (retry pills).
  /// - [tone] drives border + text color.
  const KaiButton.ghost({
    required this.onPressed,
    required this.label,
    this.icon,
    KaiButtonTone tone = KaiButtonTone.neutral,
    bool pill = false,
    this.size = KaiButtonSize.md,
    super.key,
  })  : _variant = _KaiButtonVariant.ghost,
        _fullWidth = false,
        emphasis = KaiButtonEmphasis.normal,
        _tone = tone,
        _pill = pill;

  // -------------------------------------------------------------------------
  // text
  // -------------------------------------------------------------------------

  /// No-fill, no-border text action (toast "Открыть", detail-sheet rows).
  ///
  /// [tone] drives text color.
  const KaiButton.text({
    required this.onPressed,
    required this.label,
    this.icon,
    KaiButtonTone tone = KaiButtonTone.neutral,
    this.size = KaiButtonSize.md,
    super.key,
  })  : _variant = _KaiButtonVariant.text,
        _fullWidth = false,
        emphasis = KaiButtonEmphasis.normal,
        _tone = tone,
        _pill = false;

  // -------------------------------------------------------------------------
  // Fields
  // -------------------------------------------------------------------------

  final VoidCallback? onPressed;
  final String label;
  final KaiIconName? icon;

  /// Tide emphasis — [KaiButtonEmphasis.normal] or [KaiButtonEmphasis.glow].
  /// Meaningless for non-tide variants.
  final KaiButtonEmphasis emphasis;

  /// Size tier — [KaiButtonSize.md] by default.
  final KaiButtonSize size;

  final _KaiButtonVariant _variant;
  final bool _fullWidth;
  final KaiButtonTone _tone;
  final bool _pill;

  @override
  State<KaiButton> createState() => _KaiButtonState();
}

// ---------------------------------------------------------------------------
// Internal variant enum
// ---------------------------------------------------------------------------

enum _KaiButtonVariant { tide, ink, ghost, text }

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class _KaiButtonState extends State<KaiButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  // Gradient-flow animation — only created for the tide variant and when
  // the system reduce-motion preference is not active.
  AnimationController? _gradientController;
  Animation<double>? _gradientAnim;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncGradientController();
  }

  @override
  void didUpdateWidget(KaiButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._variant != widget._variant) {
      _syncGradientController();
    }
  }

  void _syncGradientController() {
    final isTide = widget._variant == _KaiButtonVariant.tide;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (isTide && !reduceMotion) {
      if (_gradientController == null) {
        _gradientController = AnimationController(
          vsync: this,
          duration: KaiMotion.ambient, // 2600 ms
        )..repeat(reverse: true);

        _gradientAnim = CurvedAnimation(
          parent: _gradientController!,
          curve: KaiMotion.ambientCurve,
        );
      }
    } else {
      _gradientController?.dispose();
      _gradientController = null;
      _gradientAnim = null;
    }
  }

  @override
  void dispose() {
    _gradientController?.dispose();
    super.dispose();
  }

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final enabled = widget.onPressed != null;

    final fg = _fgColor(tokens);

    // Icon size per tier.
    final iconSize = switch (widget.size) {
      KaiButtonSize.sm => 16.0,
      KaiButtonSize.md => 18.0,
      KaiButtonSize.lg => 20.0,
    };

    // Label text style per tier.
    final labelStyle = switch (widget.size) {
      KaiButtonSize.sm =>
        // sm: 12.5px / w500 — toast .open / detail .act
        KaiType.micro(color: fg).copyWith(
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
        ),
      KaiButtonSize.md =>
        // md: 13.5px / w600 — canon default button (new-btn 13.5px/pad11)
        KaiType.small(color: fg).copyWith(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      KaiButtonSize.lg =>
        // lg: 15px / w600 — hero CTA (onboarding "Start", money-gate)
        KaiType.small(color: fg).copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
    };

    // Content padding per tier.
    final contentPadding = switch (widget.size) {
      KaiButtonSize.sm => const EdgeInsets.symmetric(
          vertical: KaiSpace.s2, // 8px
          horizontal: KaiSpace.s3, // 12px
        ),
      KaiButtonSize.md => const EdgeInsets.symmetric(
          vertical: KaiSpace.s3, // 12px
          horizontal: KaiSpace.s5, // 20px
        ),
      KaiButtonSize.lg => const EdgeInsets.symmetric(
          vertical: KaiSpace.s4, // 16px
          horizontal: KaiSpace.s6, // 24px
        ),
    };

    // Row axis — ink fullWidth stretches.
    final rowSize = widget._variant == _KaiButtonVariant.ink && widget._fullWidth
        ? MainAxisSize.max
        : MainAxisSize.min;

    // Content (label ± icon).
    Widget content = Row(
      mainAxisSize: rowSize,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          KaiIcon(widget.icon!, size: iconSize, color: fg),
          const SizedBox(width: KaiSpace.s2),
        ],
        Text(widget.label, style: labelStyle),
      ],
    );

    // Build the decoration — tide variant uses an animated gradient when the
    // controller is running, otherwise falls back to the static gradient.
    Widget container;

    if (widget._variant == _KaiButtonVariant.tide &&
        _gradientController != null &&
        _gradientAnim != null) {
      // Animated tide button — rebuild on every animation tick.
      container = AnimatedBuilder(
        animation: _gradientAnim!,
        builder: (context, child) {
          final t = _gradientAnim!.value; // 0.0 → 1.0 → 0.0 (reverse loop)

          // Subtle horizontal sweep: begin shifts from (-0.906, -0.423) to
          // (-0.4, -0.423) and end from (0.906, 0.423) to (1.4, 0.423).
          // This is a ~0.5 unit horizontal drift — calm tide flow, not strobe.
          final sweepX = t * 0.5;
          final animatedGradient = LinearGradient(
            colors: KaiTide.gradient.colors,
            stops: KaiTide.gradient.stops,
            begin: Alignment(-0.906 + sweepX, -0.423),
            end: Alignment(0.906 + sweepX, 0.423),
          );

          return Container(
            width: (widget._variant == _KaiButtonVariant.ink &&
                    widget._fullWidth)
                ? double.infinity
                : null,
            padding: contentPadding,
            decoration: BoxDecoration(
              gradient: animatedGradient,
              borderRadius: widget.emphasis == KaiButtonEmphasis.glow
                  ? KaiRadius.br2
                  : KaiRadius.br3,
              boxShadow: widget.emphasis == KaiButtonEmphasis.glow
                  ? KaiShadow.glow
                  : KaiShadow.button,
            ),
            child: child,
          );
        },
        child: content,
      );
    } else {
      // Static decoration (non-tide or reduce-motion).
      container = Container(
        width: (widget._variant == _KaiButtonVariant.ink && widget._fullWidth)
            ? double.infinity
            : null,
        padding: contentPadding,
        decoration: _decoration(tokens),
        child: content,
      );
    }

    final core = AnimatedScale(
      scale: _pressed && enabled ? 0.97 : 1.0,
      duration: KaiMotion.micro,
      curve: KaiMotion.standardCurve,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: container,
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        onTapCancel: enabled ? () => _setPressed(false) : null,
        onTap: enabled ? widget.onPressed : null,
        child: core,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  /// Foreground (text + icon) color for the active variant / tone.
  Color _fgColor(KaiTokens tokens) {
    final c = tokens.colors;
    switch (widget._variant) {
      case _KaiButtonVariant.tide:
      case _KaiButtonVariant.ink:
        return const Color(0xFFFFFFFF);
      case _KaiButtonVariant.ghost:
        return _toneColor(c);
      case _KaiButtonVariant.text:
        return _toneColor(c);
    }
  }

  /// Color driven by [KaiButtonTone].
  Color _toneColor(KaiColorTokens c) {
    switch (widget._tone) {
      case KaiButtonTone.neutral:
        return c.ink1;
      case KaiButtonTone.accent:
        return c.accent;
      case KaiButtonTone.warning:
        return c.warning;
      case KaiButtonTone.negative:
        return c.negative;
    }
  }

  /// Ghost border color: neutral uses the hairline `line`; toned ghosts use
  /// their tone color for both border and text.
  Color _ghostBorderColor(KaiColorTokens c) {
    switch (widget._tone) {
      case KaiButtonTone.neutral:
        return c.line;
      case KaiButtonTone.accent:
        return c.accent;
      case KaiButtonTone.warning:
        return c.warning;
      case KaiButtonTone.negative:
        return c.negative;
    }
  }

  /// Decoration for non-animated (static) path.
  Decoration _decoration(KaiTokens tokens) {
    final c = tokens.colors;
    switch (widget._variant) {
      case _KaiButtonVariant.tide:
        final isGlow = widget.emphasis == KaiButtonEmphasis.glow;
        return BoxDecoration(
          gradient: KaiTide.gradient,
          borderRadius: isGlow ? KaiRadius.br2 : KaiRadius.br3,
          boxShadow: isGlow ? KaiShadow.glow : KaiShadow.button,
        );

      case _KaiButtonVariant.ink:
        return BoxDecoration(
          color: c.ink1,
          borderRadius: widget._fullWidth ? KaiRadius.br12 : KaiRadius.br3,
        );

      case _KaiButtonVariant.ghost:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: widget._pill ? KaiRadius.brPill : KaiRadius.br3,
          border: Border.all(color: _ghostBorderColor(c)),
        );

      case _KaiButtonVariant.text:
        return const BoxDecoration(color: Colors.transparent);
    }
  }
}
