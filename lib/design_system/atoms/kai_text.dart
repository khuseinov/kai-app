import 'package:flutter/material.dart';

import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// Internal style selector — each KaiText factory binds one.
enum _KaiTextStyle { hero, display, h1, h2, h3, lead, body, small, micro, mono }

/// Typed text component — each factory maps to a [KaiType] style.
///
/// Color defaults to `ink1` from the active theme. Pass an explicit [color]
/// to override (e.g. ink2 for secondary copy).
///
/// Atoms cannot import other atoms — this widget pulls only tokens + theme +
/// flutter.
class KaiText extends StatelessWidget {
  const KaiText.hero(this.text, {this.color, this.textAlign, super.key})
      : _style = _KaiTextStyle.hero;
  const KaiText.display(this.text, {this.color, this.textAlign, super.key})
      : _style = _KaiTextStyle.display;
  const KaiText.h1(this.text, {this.color, this.textAlign, super.key})
      : _style = _KaiTextStyle.h1;
  const KaiText.h2(this.text, {this.color, this.textAlign, super.key})
      : _style = _KaiTextStyle.h2;
  const KaiText.h3(this.text, {this.color, this.textAlign, super.key})
      : _style = _KaiTextStyle.h3;
  const KaiText.lead(this.text, {this.color, this.textAlign, super.key})
      : _style = _KaiTextStyle.lead;
  const KaiText.body(this.text, {this.color, this.textAlign, super.key})
      : _style = _KaiTextStyle.body;
  const KaiText.small(this.text, {this.color, this.textAlign, super.key})
      : _style = _KaiTextStyle.small;
  const KaiText.micro(this.text, {this.color, this.textAlign, super.key})
      : _style = _KaiTextStyle.micro;
  const KaiText.mono(this.text, {this.color, this.textAlign, super.key})
      : _style = _KaiTextStyle.mono;

  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final _KaiTextStyle _style;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final c = color ?? tokens.colors.ink1;
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
    return Text(text, style: style, textAlign: textAlign);
  }
}
