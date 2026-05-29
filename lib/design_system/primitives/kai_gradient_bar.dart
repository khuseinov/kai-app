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
/// Animation modes (mutually exclusive; [streaming] takes precedence):
/// - [pulse]     — gentle scale-breathe 0.92↔1.08, [KaiMotion.ambient].
/// - [streaming] — calm opacity pulse 0.6↔1.0, representing Kai responding;
///                 slightly more active than [pulse] but still ambient-paced.
///
/// Reduced-motion (`MediaQueryData.disableAnimations`) → both modes render
/// static full-opacity with no animation; controllers are disposed correctly.
class KaiGradientBar extends StatefulWidget {
  const KaiGradientBar({
    super.key,
    this.width = 16,
    this.height = 4,
    this.pulse = false,
    this.streaming = false,
  });

  final double width;
  final double height;

  /// When `true`, adds a gentle scale-breathe animation.
  final bool pulse;

  /// When `true`, adds a calm opacity pulse (0.6↔1.0) representing
  /// "Kai is responding". Takes precedence over [pulse] if both are set.
  final bool streaming;

  @override
  State<KaiGradientBar> createState() => _KaiGradientBarState();
}

class _KaiGradientBarState extends State<KaiGradientBar>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _scale;
  Animation<double>? _opacity;

  bool get _wantPulse => widget.pulse && !widget.streaming;
  bool get _wantStreaming => widget.streaming;
  bool get _wantAnimation => _wantPulse || _wantStreaming;

  @override
  void initState() {
    super.initState();
    _startIfNeeded();
  }

  @override
  void didUpdateWidget(covariant KaiGradientBar old) {
    super.didUpdateWidget(old);
    final wasAnimating = (old.pulse && !old.streaming) || old.streaming;
    if (wasAnimating != _wantAnimation) {
      _controller?.dispose();
      _controller = null;
      _scale = null;
      _opacity = null;
      _startIfNeeded();
    }
  }

  void _startIfNeeded() {
    if (!_wantAnimation) return;
    _controller = AnimationController(
      vsync: this,
      duration: KaiMotion.ambient,
    )..repeat(reverse: true);

    if (_wantStreaming) {
      _opacity = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller!,
          curve: KaiMotion.ambientCurve,
        ),
      );
    } else {
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
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (!_wantAnimation || _controller == null || disableAnimations) {
      return _bar();
    }

    if (_wantStreaming && _opacity != null) {
      return AnimatedBuilder(
        animation: _opacity!,
        builder: (context, child) => Opacity(
          opacity: _opacity!.value,
          child: child,
        ),
        child: _bar(),
      );
    }

    // pulse
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
