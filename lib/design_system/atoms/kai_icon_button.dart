import 'package:flutter/material.dart';
import 'package:kai_app/design_system/primitives/primitives.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

// ---------------------------------------------------------------------------
// Size enum
// ---------------------------------------------------------------------------

/// Size variants for [KaiIconButton].
///
/// - [sm] → icon 16px / tap target 28px (16 + 6px padding each side).
/// - [md] → icon 18px / tap target 30px (18 + 6px padding each side) — default.
enum KaiIconButtonSize {
  /// Icon 16px, tap target 28px.
  sm,

  /// Icon 18px, tap target 30px (default).
  md,
}

// ---------------------------------------------------------------------------
// Internal variant
// ---------------------------------------------------------------------------

enum _KaiIconButtonVariant { surface, transparent, bare, toggle }

// ---------------------------------------------------------------------------
// KaiIconButton
// ---------------------------------------------------------------------------

/// v3 icon-only button — four named-constructor variants.
///
/// ### Variants
/// - `KaiIconButton.surface` — surface2 background, brPill, ink2 icon.
///   Canon: compose-island attachment/gallery buttons.
/// - `KaiIconButton.transparent` — no background, ink3 icon.
///   Canon: compose-island mic button (30×30 with 6px padding).
/// - `KaiIconButton.bare` — no background, color-overridable icon (defaults
///   to ink2). Canon: sheet close, nav actions.
/// - `KaiIconButton.toggle` — active: accent icon on accentWash pill (brPill);
///   inactive: transparent + ink3.
///
/// ### Sizing
/// Pass [iconSize] ([KaiIconButtonSize.sm] or [KaiIconButtonSize.md]) to pick
/// canonical sizes (sm=16px icon, md=18px icon). For precise pixel overrides
/// (e.g. canon reaction icons at 11px), use the raw [size] `double` param.
/// When both are supplied, [size] wins.
///
/// ### Common behaviour
/// - Press → [AnimatedScale] 0.97 with [KaiMotion.micro] +
///   [KaiMotion.standardCurve].
/// - Disabled (`onPressed == null`) → [Opacity](0.5), no tap.
/// - [Semantics](button: true, enabled, label: icon.assetName).
class KaiIconButton extends StatefulWidget {
  // -------------------------------------------------------------------------
  // surface
  // -------------------------------------------------------------------------

  /// Surface2 fill, brPill radius, ink2 icon.
  const KaiIconButton.surface({
    required this.onPressed,
    required this.icon,
    this.iconSize = KaiIconButtonSize.md,
    double? size,
    super.key,
  })  : _variant = _KaiIconButtonVariant.surface,
        _color = null,
        _active = false,
        _sizeOverride = size;

  // -------------------------------------------------------------------------
  // transparent
  // -------------------------------------------------------------------------

  /// No background, ink3 icon. Canon mic in compose-island.
  const KaiIconButton.transparent({
    required this.onPressed,
    required this.icon,
    this.iconSize = KaiIconButtonSize.md,
    double? size,
    super.key,
  })  : _variant = _KaiIconButtonVariant.transparent,
        _color = null,
        _active = false,
        _sizeOverride = size;

  // -------------------------------------------------------------------------
  // bare
  // -------------------------------------------------------------------------

  /// No background, color-overridable icon (defaults to ink2).
  const KaiIconButton.bare({
    required this.onPressed,
    required this.icon,
    Color? color,
    this.iconSize = KaiIconButtonSize.md,
    double? size,
    super.key,
  })  : _variant = _KaiIconButtonVariant.bare,
        _color = color,
        _active = false,
        _sizeOverride = size;

  // -------------------------------------------------------------------------
  // toggle
  // -------------------------------------------------------------------------

  /// Toggle icon button.
  ///
  /// [active] true → accent icon on accentWash pill (brPill).
  /// [active] false → transparent background, ink3 icon.
  const KaiIconButton.toggle({
    required bool active,
    required this.onPressed,
    required this.icon,
    this.iconSize = KaiIconButtonSize.md,
    super.key,
  })  : _variant = _KaiIconButtonVariant.toggle,
        _active = active,
        _color = null,
        _sizeOverride = null;

  // -------------------------------------------------------------------------
  // Fields
  // -------------------------------------------------------------------------

  final VoidCallback? onPressed;

  /// Icon glyph to render. Passed to [KaiIcon].
  final KaiIconName icon;

  /// Canonical size selector (default [KaiIconButtonSize.md]).
  ///
  /// Ignored when [_sizeOverride] is set.
  final KaiIconButtonSize iconSize;

  final _KaiIconButtonVariant _variant;

  /// Override icon color for [KaiIconButton.bare]. Ignored by other variants.
  final Color? _color;

  /// Active state for [KaiIconButton.toggle]. Ignored by other variants.
  final bool _active;

  /// Raw pixel override for the icon glyph size.
  ///
  /// When non-null, this wins over [iconSize]. Used for canon pixel-accurate
  /// call sites (e.g. reaction icons at 11px).
  final double? _sizeOverride;

  @override
  State<KaiIconButton> createState() => _KaiIconButtonState();
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class _KaiIconButtonState extends State<KaiIconButton> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  /// Resolved icon glyph size in logical pixels.
  double get _resolvedIconSize {
    if (widget._sizeOverride != null) return widget._sizeOverride!;
    switch (widget.iconSize) {
      case KaiIconButtonSize.sm:
        return 16;
      case KaiIconButtonSize.md:
        return 18;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final enabled = widget.onPressed != null;

    final iconColor = _iconColor(tokens);
    final decoration = _decoration(tokens);

    // 6px padding on all sides (KaiSpace.s1 (4) + 2 = 6).
    const padding = EdgeInsets.all(KaiSpace.s1 + 2);

    final Widget core = AnimatedScale(
      scale: _pressed && enabled ? 0.97 : 1.0,
      duration: KaiMotion.micro,
      curve: KaiMotion.standardCurve,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          padding: padding,
          decoration: decoration,
          child: KaiIcon(widget.icon, size: _resolvedIconSize, color: iconColor),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.icon.assetName,
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

  Color _iconColor(KaiTokens tokens) {
    final c = tokens.colors;
    switch (widget._variant) {
      case _KaiIconButtonVariant.surface:
        return c.ink2;
      case _KaiIconButtonVariant.transparent:
        return c.ink3;
      case _KaiIconButtonVariant.bare:
        return widget._color ?? c.ink2;
      case _KaiIconButtonVariant.toggle:
        return widget._active ? c.accent : c.ink3;
    }
  }

  Decoration? _decoration(KaiTokens tokens) {
    switch (widget._variant) {
      case _KaiIconButtonVariant.surface:
        return BoxDecoration(
          color: tokens.colors.surface2,
          borderRadius: KaiRadius.brPill,
        );
      case _KaiIconButtonVariant.toggle:
        if (widget._active) {
          return BoxDecoration(
            color: tokens.colors.accentWash,
            borderRadius: KaiRadius.brPill,
          );
        }
        return null;
      case _KaiIconButtonVariant.transparent:
      case _KaiIconButtonVariant.bare:
        return null;
    }
  }
}
