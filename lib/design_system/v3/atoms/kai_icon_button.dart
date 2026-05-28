import 'package:flutter/material.dart';

import '../../theme/kai_theme.dart';
import '../../tokens/kai_tokens.dart';
import '../primitives/primitives.dart';

// ---------------------------------------------------------------------------
// Internal variant
// ---------------------------------------------------------------------------

enum _KaiIconButtonVariant { surface, transparent, bare }

// ---------------------------------------------------------------------------
// KaiIconButton
// ---------------------------------------------------------------------------

/// v3 icon-only button — three named-constructor variants.
///
/// ### Variants
/// - `KaiIconButton.surface` — surface2 background, brPill, ink2 icon.
///   Canon: compose-island attachment/gallery buttons.
/// - `KaiIconButton.transparent` — no background, ink3 icon.
///   Canon: compose-island mic button (30×30 with 6px padding).
/// - `KaiIconButton.bare` — no background, color-overridable icon (defaults
///   to ink2). Canon: sheet close, nav actions.
///
/// ### Common behaviour
/// - Default [size] 18 (glyph side) + 6px padding on all sides → 30×30 tap
///   target. 6px = `KaiSpace.s1 + 2` (s1 == 4, + 2 == 6).
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
    this.size = 18,
    super.key,
  })  : _variant = _KaiIconButtonVariant.surface,
        _color = null;

  // -------------------------------------------------------------------------
  // transparent
  // -------------------------------------------------------------------------

  /// No background, ink3 icon. Canon mic in compose-island.
  const KaiIconButton.transparent({
    required this.onPressed,
    required this.icon,
    this.size = 18,
    super.key,
  })  : _variant = _KaiIconButtonVariant.transparent,
        _color = null;

  // -------------------------------------------------------------------------
  // bare
  // -------------------------------------------------------------------------

  /// No background, color-overridable icon (defaults to ink2).
  const KaiIconButton.bare({
    required this.onPressed,
    required this.icon,
    Color? color,
    this.size = 18,
    super.key,
  })  : _variant = _KaiIconButtonVariant.bare,
        _color = color;

  // -------------------------------------------------------------------------
  // Fields
  // -------------------------------------------------------------------------

  final VoidCallback? onPressed;

  /// Icon glyph to render. Passed to [KaiIcon].
  final KaiIconName icon;

  /// Icon glyph size in logical pixels. Default 18.
  /// The tap target is always [size] + 12 (6px padding each side).
  final double size;

  final _KaiIconButtonVariant _variant;

  /// Override icon color for [KaiIconButton.bare]. Ignored by other variants.
  final Color? _color;

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

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final enabled = widget.onPressed != null;

    final iconColor = _iconColor(tokens);
    final decoration = _decoration(tokens);

    // 6px padding: KaiSpace.s1 (4) + 2 = 6.
    const padding = EdgeInsets.all(KaiSpace.s1 + 2);

    Widget core = AnimatedScale(
      scale: _pressed && enabled ? 0.97 : 1.0,
      duration: KaiMotion.micro,
      curve: KaiMotion.standardCurve,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          padding: padding,
          decoration: decoration,
          child: KaiIcon(widget.icon, size: widget.size, color: iconColor),
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
    }
  }

  Decoration? _decoration(KaiTokens tokens) {
    switch (widget._variant) {
      case _KaiIconButtonVariant.surface:
        return BoxDecoration(
          color: tokens.colors.surface2,
          borderRadius: KaiRadius.brPill,
        );
      case _KaiIconButtonVariant.transparent:
      case _KaiIconButtonVariant.bare:
        return null;
    }
  }
}
