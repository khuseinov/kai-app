import 'package:flutter/material.dart';

import '../tokens/kai_motion.dart';
import '../tokens/kai_radius.dart';
import '../tokens/kai_tide.dart';

/// Primitive tide-gradient rounded pill.
///
/// Renders a pill (`KaiRadius.brPill`) filled with `KaiTide.gradient`.
///
/// Canon sizes:
/// - Kai "who" glyph: `width: 16, height: 4`  (the default)
/// - Toast tide-bar:  `width: 10, height: 2.5`
///
/// When [pulse] is `false` (default) this is a plain [StatelessWidget].
/// When [pulse] is `true` a gentle scale animation drives the breath cycle
/// using [KaiMotion.ambient] duration and [KaiMotion.ambientCurve]; the
/// widget becomes [StatefulWidget]-backed and disposes the controller cleanly.
class KaiGradientBar extends StatefulWidget {
  const KaiGradientBar({
    super.key,
    this.width = 16,
    this.height = 4,
    this.pulse = false,
  });

  final double width;
  final double height;

  /// When `true`, adds a gentle scale-breathe animation.
  final bool pulse;

  @override
  State<KaiGradientBar> createState() => _KaiGradientBarState();
}

class _KaiGradientBarState extends State<KaiGradientBar>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _scale;

  @override
  void initState() {
    super.initState();
    if (widget.pulse) {
      _controller = AnimationController(
        vsync: this,
        duration: KaiMotion.ambient,
      )..repeat(reverse: true);
      _scale = Tween<double>(begin: 0.92, end: 1.08).animate(
        CurvedAnimation(
          parent: _controller!,
          curve: KaiMotion.ambientCurve,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _bar() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: const BoxDecoration(
        gradient: KaiTide.gradient,
        borderRadius: KaiRadius.brPill,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.pulse || _controller == null) {
      return _bar();
    }
    return AnimatedBuilder(
      animation: _scale!,
      builder: (context, child) => Transform.scale(
        scale: _scale!.value,
        child: child,
      ),
      child: _bar(),
    );
  }
}
