import 'package:flutter/material.dart';

import '../theme/kai_theme.dart';

/// v3 hairline divider atom.
///
/// Two constructors:
/// - [KaiDivider()] — horizontal 1px line, fills available width (full-bleed).
/// - [KaiDivider.vertical()] — vertical 1px line, fills available height.
///
/// Color defaults to `line` from the active theme. Pass an explicit [color] to
/// override.
///
/// The 1px thickness is the canonical hairline; it is intentionally a literal
/// rather than a token — a divider is defined as exactly one physical-pixel
/// equivalent at 1 logical pixel.
class KaiDivider extends StatelessWidget {
  /// Horizontal hairline — 1px tall, full available width.
  const KaiDivider({this.color, super.key}) : _vertical = false;

  /// Vertical hairline — 1px wide, full available height.
  const KaiDivider.vertical({this.color, super.key}) : _vertical = true;

  /// Optional color override. Defaults to `KaiTheme.of(context).colors.line`.
  final Color? color;

  final bool _vertical;

  @override
  Widget build(BuildContext context) {
    final lineColor = color ?? KaiTheme.of(context).colors.line;
    final decoration = BoxDecoration(color: lineColor);

    if (_vertical) {
      return Container(
        constraints: const BoxConstraints.expand(width: 1),
        decoration: decoration,
      );
    }
    return Container(
      constraints: const BoxConstraints.expand(height: 1),
      decoration: decoration,
    );
  }
}
