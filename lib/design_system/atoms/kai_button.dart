import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';
import 'kai_icon.dart' show KaiIconName;

/// Internal variant selector.
enum _KaiButtonVariant { tide, ink1, ghost, icon }

/// Atomic button — four visual variants:
///
/// - `KaiButton.tide` — primary action, tide gradient + soft shadow + white text.
/// - `KaiButton.ink1` — solid ink-1 fill + white text.
/// - `KaiButton.ghost` — transparent + 1px ink-3 border + ink-1 text.
/// - `KaiButton.icon` — icon-only pill, ink-2 tint.
///
/// `onPressed == null` disables the button (opacity 0.5, no tap).
///
/// Atoms cannot import other atoms — labels render via raw `Text(style:
/// KaiType.body(...))`; the optional [icon] param uses the [KaiIconName] enum
/// (a const enum, not a widget) and we paint the SVG inline with
/// `SvgPicture.asset` to keep KaiButton boundary-clean.
class KaiButton extends StatefulWidget {
  const KaiButton.tide({
    required this.onPressed,
    required this.label,
    this.icon,
    super.key,
  })  : _variant = _KaiButtonVariant.tide,
        _iconSize = null;

  const KaiButton.ink1({
    required this.onPressed,
    required this.label,
    this.icon,
    super.key,
  })  : _variant = _KaiButtonVariant.ink1,
        _iconSize = null;

  const KaiButton.ghost({
    required this.onPressed,
    required this.label,
    this.icon,
    super.key,
  })  : _variant = _KaiButtonVariant.ghost,
        _iconSize = null;

  const KaiButton.icon({
    required this.onPressed,
    required KaiIconName this.icon,
    double? size,
    super.key,
  })  : _variant = _KaiButtonVariant.icon,
        label = '',
        _iconSize = size;

  final VoidCallback? onPressed;
  final String label;
  final KaiIconName? icon;
  final _KaiButtonVariant _variant;
  final double? _iconSize;

  @override
  State<KaiButton> createState() => _KaiButtonState();
}

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
    final decoration = _buildDecoration(tokens, enabled);
    final padding = widget._variant == _KaiButtonVariant.icon
        // Canon: room.html `.compose-island .mic, .send { width: 30px;
        // height: 30px; }` — with an 18px glyph that means 6px padding.
        ? const EdgeInsets.all(KaiSpace.s1 + 2)
        : const EdgeInsets.symmetric(
            vertical: KaiSpace.s3,
            horizontal: KaiSpace.s5,
          );

    final content = widget._variant == _KaiButtonVariant.icon
        ? _iconOnly(tokens)
        : _labelAndIcon(tokens);

    final core = AnimatedScale(
      scale: _pressed && enabled ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          padding: padding,
          decoration: decoration,
          child: content,
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget._variant == _KaiButtonVariant.icon
          ? (widget.icon?.assetName ?? 'button')
          : widget.label,
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

  BoxDecoration _buildDecoration(KaiTokens tokens, bool enabled) {
    final c = tokens.colors;
    switch (widget._variant) {
      case _KaiButtonVariant.tide:
        return const BoxDecoration(
          gradient: KaiTide.gradient,
          borderRadius: KaiRadius.br3,
          boxShadow: [
            BoxShadow(
              color: Color(0x2E2BA8C9), // rgba(43,168,201,0.18) -> 0x2E
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        );
      case _KaiButtonVariant.ink1:
        return BoxDecoration(
          color: c.ink1,
          borderRadius: KaiRadius.br3,
        );
      case _KaiButtonVariant.ghost:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: KaiRadius.br3,
          border: Border.all(color: c.ink3, width: 1),
        );
      case _KaiButtonVariant.icon:
        return BoxDecoration(
          color: c.surface2,
          borderRadius: KaiRadius.brPill,
        );
    }
  }

  Widget _labelAndIcon(KaiTokens tokens) {
    final labelColor = _labelColor(tokens);
    final labelStyle = KaiType.body(color: labelColor).copyWith(
      fontWeight: FontWeight.w600,
    );
    final labelWidget = Text(widget.label, style: labelStyle);

    if (widget.icon == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [labelWidget],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/icons/${widget.icon!.assetName}.svg',
          width: 18,
          height: 18,
          colorFilter: ColorFilter.mode(labelColor, BlendMode.srcIn),
        ),
        const SizedBox(width: KaiSpace.s2),
        labelWidget,
      ],
    );
  }

  Widget _iconOnly(KaiTokens tokens) {
    final c = tokens.colors;
    final size = widget._iconSize ?? 18;
    return SvgPicture.asset(
      'assets/icons/${widget.icon!.assetName}.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(c.ink2, BlendMode.srcIn),
    );
  }

  Color _labelColor(KaiTokens tokens) {
    switch (widget._variant) {
      case _KaiButtonVariant.tide:
      case _KaiButtonVariant.ink1:
        return const Color(0xFFFFFFFF);
      case _KaiButtonVariant.ghost:
        return tokens.colors.ink1;
      case _KaiButtonVariant.icon:
        return tokens.colors.ink2;
    }
  }
}
