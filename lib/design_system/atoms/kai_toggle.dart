import 'package:flutter/material.dart';

import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// v3 pill switch — atomic. Canon: `new-design/settings.html § .toggle`.
///
/// ```
/// Track: 34 × 20 pill (KaiRadius.brPill), inner padding 2
/// Thumb: 16 × 16 circle (BoxShape.circle), white, KaiShadow.thumb
/// Track color: surface3 (off) | accent (on)
/// Thumb animation: KaiMotion.standard / KaiMotion.standardCurve via AnimatedAlign
/// Disabled: Opacity(0.5), onChanged == null → no tap
/// ```
///
/// Dimension constants (inherent component sizes, not design-scale tokens):
/// - [_trackWidth]  = 34 logical pixels
/// - [_trackHeight] = 20 logical pixels
/// - [_thumbSize]   = 16 logical pixels
/// - [_padding]     = 2 logical pixels (inner track padding)
class KaiToggle extends StatelessWidget {
  const KaiToggle({
    required this.value,
    required this.onChanged,
    this.activeColor,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;

  // -------------------------------------------------------------------------
  // Component dimensions (canonical; documented above — not token-scale values)
  // -------------------------------------------------------------------------

  static const double _trackWidth = 34;
  static const double _trackHeight = 20;
  static const double _thumbSize = 16;
  static const double _padding = 2;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final enabled = onChanged != null;

    Widget track = AnimatedContainer(
      duration: KaiMotion.standard,
      curve: KaiMotion.standardCurve,
      width: _trackWidth,
      height: _trackHeight,
      padding: const EdgeInsets.all(_padding),
      decoration: BoxDecoration(
        color: value ? (activeColor ?? c.accent) : c.surface3,
        borderRadius: KaiRadius.brPill,
      ),
      child: AnimatedAlign(
        duration: KaiMotion.standard,
        curve: KaiMotion.standardCurve,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: _thumbSize,
          height: _thumbSize,
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF), // sanctioned white-on-fill literal
            shape: BoxShape.circle,
            boxShadow: KaiShadow.thumb,
          ),
        ),
      ),
    );

    return Semantics(
      toggled: value,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => onChanged!(!value) : null,
        child: Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: track,
        ),
      ),
    );
  }
}
