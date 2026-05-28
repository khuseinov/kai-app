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

// ---------------------------------------------------------------------------
// KaiButton
// ---------------------------------------------------------------------------

/// v3 keystone button — four named-constructor variants.
///
/// ### Variants
/// - `KaiButton.tide` — primary action (tide gradient). Supports
///   [KaiButtonEmphasis.normal] (br3, soft shadow) and
///   [KaiButtonEmphasis.glow] (br2, diffuse glow — money-gate canon).
/// - `KaiButton.ink` — solid ink-1 secondary. `fullWidth: true` stretches to
///   the drawer "new chat" canon (ink1, br12, full-width).
/// - `KaiButton.ghost` — outline button. `pill: true` → brPill for retry pills.
///   [KaiButtonTone] drives border + text color.
/// - `KaiButton.text` — no fill, no border (toast "Открыть", detail-sheet
///   row actions). [KaiButtonTone] drives text color.
///
/// ### Common behaviour
/// - `onPressed == null` → disabled: opacity 0.5, no tap.
/// - Press → [AnimatedScale] to 0.97, duration [KaiMotion.micro] (120 ms),
///   curve [KaiMotion.standardCurve].
/// - Label: [Text] + `KaiType.body(color: fg).copyWith(fontWeight: w600)`.
/// - Icon (when provided): [KaiIcon](name, size: 18, color: fg) left of label,
///   [SizedBox](width: KaiSpace.s2) gap.
/// - Padding: `vertical: KaiSpace.s3 / horizontal: KaiSpace.s5` (12 / 20).
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

class _KaiButtonState extends State<KaiButton> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final enabled = widget.onPressed != null;

    final fg = _fgColor(tokens);
    final decoration = _decoration(tokens);

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
          KaiIcon(widget.icon!, size: 18, color: fg),
          const SizedBox(width: KaiSpace.s2),
        ],
        Text(
          widget.label,
          style: KaiType.body(color: fg).copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );

    // Outer container.
    Widget container = Container(
      width: (widget._variant == _KaiButtonVariant.ink && widget._fullWidth)
          ? double.infinity
          : null,
      padding: const EdgeInsets.symmetric(
        vertical: KaiSpace.s3,
        horizontal: KaiSpace.s5,
      ),
      decoration: decoration,
      child: content,
    );

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

  /// Decoration for the active variant.
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
