import 'package:flutter/material.dart';

import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// Internal style selector — each KaiText factory binds one.
enum _KaiTextStyle { hero, display, h1, h2, h3, lead, body, small, micro, mono }

/// v3 typed text atom — each factory maps to a [KaiType] style.
///
/// Color defaults to `ink1` from the active theme. Pass an explicit [color]
/// to override (e.g. `ink2` for secondary copy).
///
/// **Tide-gradient emphasis** — the display-tier constructors (`hero`, `display`,
/// `h1`, `h2`, `h3`) accept an optional `gradient: true` flag. When enabled, the
/// text is painted with [KaiTide.gradient] via a [ShaderMask] (BlendMode.srcIn).
/// The underlying text color is set to white so the gradient shows fully.
///
/// Partial-word gradient (one word inside a sentence) is composed at the **call
/// site** — use a `Row` or `Wrap` of two KaiText widgets. `KaiText` itself
/// gradient-fills its entire string.
///
/// Body / small / micro / mono do not support gradient — they never carry display
/// emphasis.
///
/// Atoms must NOT import other atoms. This widget pulls only tokens + theme +
/// flutter.
class KaiText extends StatelessWidget {
  // Display-tier constructors — support gradient emphasis.
  const KaiText.hero(
    this.text, {
    this.color,
    this.textAlign,
    this.gradient = false,
    super.key,
  }) : _style = _KaiTextStyle.hero;

  const KaiText.display(
    this.text, {
    this.color,
    this.textAlign,
    this.gradient = false,
    super.key,
  }) : _style = _KaiTextStyle.display;

  const KaiText.h1(
    this.text, {
    this.color,
    this.textAlign,
    this.gradient = false,
    super.key,
  }) : _style = _KaiTextStyle.h1;

  const KaiText.h2(
    this.text, {
    this.color,
    this.textAlign,
    this.gradient = false,
    super.key,
  }) : _style = _KaiTextStyle.h2;

  const KaiText.h3(
    this.text, {
    this.color,
    this.textAlign,
    this.gradient = false,
    super.key,
  }) : _style = _KaiTextStyle.h3;

  // Body-tier constructors — no gradient param.
  const KaiText.lead(
    this.text, {
    this.color,
    this.textAlign,
    super.key,
  })  : _style = _KaiTextStyle.lead,
        gradient = false;

  const KaiText.body(
    this.text, {
    this.color,
    this.textAlign,
    super.key,
  })  : _style = _KaiTextStyle.body,
        gradient = false;

  const KaiText.small(
    this.text, {
    this.color,
    this.textAlign,
    super.key,
  })  : _style = _KaiTextStyle.small,
        gradient = false;

  const KaiText.micro(
    this.text, {
    this.color,
    this.textAlign,
    super.key,
  })  : _style = _KaiTextStyle.micro,
        gradient = false;

  const KaiText.mono(
    this.text, {
    this.color,
    this.textAlign,
    super.key,
  })  : _style = _KaiTextStyle.mono,
        gradient = false;

  final String text;
  final Color? color;
  final TextAlign? textAlign;

  /// When `true` (display-tier only), the text is rendered with [KaiTide.gradient]
  /// via a [ShaderMask]. Has no effect on body-tier constructors (always false).
  final bool gradient;

  final _KaiTextStyle _style;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    // Gradient mode: use white so ShaderMask srcIn shows the gradient fully.
    // Normal mode: fall back to ink1 from theme.
    final c = gradient ? Colors.white : (color ?? tokens.colors.ink1);

    final style = switch (_style) {
      _KaiTextStyle.hero => KaiType.hero(color: c),
      _KaiTextStyle.display => KaiType.display(color: c),
      _KaiTextStyle.h1 => KaiType.h1(color: c),
      _KaiTextStyle.h2 => KaiType.h2(color: c),
      _KaiTextStyle.h3 => KaiType.h3(color: c),
      _KaiTextStyle.lead => KaiType.lead(color: c),
      _KaiTextStyle.body => KaiType.body(color: c),
      _KaiTextStyle.small => KaiType.small(color: c),
      _KaiTextStyle.micro => KaiType.micro(color: c),
      _KaiTextStyle.mono => KaiType.mono(color: c),
    };

    final textWidget = Text(text, style: style, textAlign: textAlign);

    if (!gradient) return textWidget;

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => KaiTide.gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: textWidget,
    );
  }
}
