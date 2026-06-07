import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// Resolved per-frame paint values for the tide curve.
class _TideFrame {
  const _TideFrame({
    required this.strokeWidth,
    required this.opacity,
    required this.useGradient,
    required this.solidColor,
    required this.dashPattern,
    required this.dashOffset,
    required this.translateX,
  });

  final double strokeWidth;
  final double opacity;
  final bool useGradient;

  /// Used when [useGradient] is false.
  final Color solidColor;

  /// `null` = solid line. `[on, off]` for dashed.
  final List<double>? dashPattern;

  /// Distance offset along path for dash phase.
  final double dashOffset;

  /// Horizontal translation (used by wobble).
  final double translateX;
}

/// v3 — Kai's living tide curve.
///
/// Renders an SVG path (`M 0 14 Q 60 8 120 14 T 240 12`, viewBox 240x28)
/// with state-specific stroke width, opacity, colour (solid or tide
/// gradient), dash pattern, and animation. Honors
/// `MediaQuery.disableAnimationsOf` for accessibility.
///
/// Ephemeral states (success / error / memory) auto-revert to the
/// pre-ephemeral state once their cycles complete.
///
/// Set [demoLoop] to `true` in Storybook demos to keep ephemeral states
/// looping instead of reverting — this has no effect on non-ephemeral states
/// and is never set in production code.
///
/// Faithful port of `lib/design_system/atoms/kai_tide_curve.dart` with
/// import paths adjusted for the v3 layer.
class KaiTideCurve extends StatefulWidget {
  const KaiTideCurve({
    required this.state,
    this.height = 28,
    this.demoLoop = false,
    super.key,
  });

  /// One of the 8 tuned states from [KaiTide].
  final KaiTideState state;
  final double height;

  /// When `true`, ephemeral states loop indefinitely instead of reverting to
  /// their restore state. Intended for Storybook demos only — never set this
  /// in production code. Has no effect on non-ephemeral states.
  final bool demoLoop;

  @override
  State<KaiTideCurve> createState() => _KaiTideCurveState();
}

class _KaiTideCurveState extends State<KaiTideCurve>
    with TickerProviderStateMixin {
  AnimationController? _controller;

  /// Set when an ephemeral state replaces a non-ephemeral one — the
  /// rendered state reverts here once the ephemeral cycles finish.
  KaiTideState? _restoreToState;

  /// Effective state for painting. Always tracks the prop unless we're
  /// mid-ephemeral, in which case it's the ephemeral state until reverted.
  late KaiTideState _renderState;

  /// For ephemeral states that compose multiple cycles + delays.
  int _ephemeralCyclesRemaining = 0;

  @override
  void initState() {
    super.initState();
    _renderState = widget.state;
    _wireAnimation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disabled = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disabled) {
      _controller?.stop();
    }
  }

  @override
  void didUpdateWidget(covariant KaiTideCurve old) {
    super.didUpdateWidget(old);
    if (old.state.name != widget.state.name) {
      if (widget.state.ephemeral) {
        _restoreToState = old.state.ephemeral ? _restoreToState : old.state;
      } else {
        _restoreToState = null;
      }
      _renderState = widget.state;
      _disposeController();
      final disabled = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (!disabled) {
        _wireAnimation();
      }
    }
  }


  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
  }

  /// Build the AnimationController for the current state, kick it off
  /// according to the state's animation type.
  void _wireAnimation() {
    final s = _renderState;
    switch (s.animation) {
      case KaiTideAnimation.none:
        _controller = null;
        return;
      case KaiTideAnimation.breathe:
        _controller = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: s.durationMs ?? 5500),
        )..repeat(reverse: true);
        return;
      case KaiTideAnimation.bob:
        _controller = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: s.durationMs ?? 2200),
        )..repeat(reverse: true);
        return;
      case KaiTideAnimation.flow:
        _controller = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: s.durationMs ?? 3000),
        )..repeat(reverse: false);
        return;
      case KaiTideAnimation.stream:
        _controller = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: s.durationMs ?? 1400),
        )..repeat(reverse: false);
        return;
      case KaiTideAnimation.flash:
        _ephemeralCyclesRemaining = 3;
        _runEphemeralCycle(Duration(milliseconds: s.durationMs ?? 1200));
        return;
      case KaiTideAnimation.wobble:
        _ephemeralCyclesRemaining = 2;
        _runEphemeralCycle(
          Duration(milliseconds: s.durationMs ?? 600),
          gapMs: 1000,
        );
        return;
      case KaiTideAnimation.pop:
        _ephemeralCyclesRemaining = 3;
        _runEphemeralCycle(
          Duration(milliseconds: s.durationMs ?? 900),
          gapMs: 500,
        );
        return;
    }
  }

  /// Drives one ephemeral cycle, then either reschedules the next cycle
  /// (with optional gap) or reverts to [_restoreToState].
  void _runEphemeralCycle(Duration duration, {int gapMs = 0}) {
    _controller?.dispose();
    final c = AnimationController(vsync: this, duration: duration);
    _controller = c;
    c.addStatusListener((status) {
      if (status != AnimationStatus.completed) return;
      _ephemeralCyclesRemaining -= 1;
      if (_ephemeralCyclesRemaining > 0) {
        if (gapMs > 0) {
          Future.delayed(Duration(milliseconds: gapMs), () {
            if (!mounted) return;
            _runEphemeralCycle(duration, gapMs: gapMs);
          });
        } else {
          // Defer via microtask so we don't dispose the current
          // controller (whose status listener is mid-execution) on this
          // call stack — that would be use-after-dispose. Affected:
          // KaiTide.success (3 flash cycles, gapMs=0).
          Future.microtask(() {
            if (!mounted) return;
            _runEphemeralCycle(duration, gapMs: gapMs);
          });
        }
      } else {
        // Done — either loop (demoLoop) or auto-revert (production).
        if (!mounted) return;
        if (widget.demoLoop) {
          // Re-trigger the same ephemeral state so it keeps animating for
          // demo display. Non-ephemeral states never reach this branch.
          _wireAnimation();
        } else {
          // Production: revert to the pre-ephemeral state.
          final restore = _restoreToState ?? KaiTide.idle;
          _restoreToState = null;
          setState(() => _renderState = restore);
          _disposeController();
          _wireAnimation();
        }
      }
    });
    c.forward();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final disableAnims = MediaQuery.disableAnimationsOf(context);
    final controller = _controller;

    return AnimatedBuilder(
      animation: controller ?? const AlwaysStoppedAnimation<double>(0),
      builder: (_, __) {
        final t = (disableAnims || controller == null) ? 0.0 : controller.value;
        final frame = _resolveFrame(_renderState, t, tokens);
        return Transform.translate(
          offset: Offset(frame.translateX, 0),
          child: CustomPaint(
            size: Size(double.infinity, widget.height),
            painter: _TidePainter(frame: frame),
          ),
        );
      },
    );
  }
}

_TideFrame _resolveFrame(KaiTideState state, double t, KaiTokens tokens) {
  switch (state.animation) {
    case KaiTideAnimation.none:
      return _frameNone(state, tokens);
    case KaiTideAnimation.breathe:
      return _frameBreathe(state, t, tokens);
    case KaiTideAnimation.bob:
      return _frameBob(state, t, tokens);
    case KaiTideAnimation.flow:
      return _frameFlow(state, t, tokens);
    case KaiTideAnimation.stream:
      return _frameStream(state, t, tokens);
    case KaiTideAnimation.flash:
      return _frameFlash(state, t, tokens);
    case KaiTideAnimation.wobble:
      return _frameWobble(state, t, tokens);
    case KaiTideAnimation.pop:
      return _framePop(state, t, tokens);
  }
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

_TideFrame _frameNone(KaiTideState s, KaiTokens tokens) => _TideFrame(
      strokeWidth: s.strokePx,
      opacity: s.opacity,
      useGradient: s.useGradient,
      solidColor: tokens.colors.ink4,
      dashPattern: s.dashPattern,
      dashOffset: 0,
      translateX: 0,
    );

/// idle / sleep — HTML canon breathe.
_TideFrame _frameBreathe(KaiTideState s, double t, KaiTokens tokens) {
  final eased = KaiMotion.ambientCurve.transform(t);
  final sw = _lerp(s.breatheStrokeFrom ?? s.strokePx,
      s.breatheStrokeTo ?? s.strokePx, eased);
  final op = _lerp(s.breatheOpacityFrom ?? s.opacity,
      s.breatheOpacityTo ?? s.opacity, eased);
  return _TideFrame(
    strokeWidth: sw,
    opacity: op,
    useGradient: false,
    solidColor: tokens.colors.ink4,
    dashPattern: null,
    dashOffset: 0,
    translateX: 0,
  );
}

/// listening — bob.
_TideFrame _frameBob(KaiTideState s, double t, KaiTokens tokens) {
  final eased = KaiMotion.ambientCurve.transform(t);
  return _TideFrame(
    strokeWidth: _lerp(1.6, 2.6, eased),
    opacity: _lerp(0.7, 0.9, eased),
    useGradient: true,
    solidColor: tokens.colors.ink4,
    dashPattern: null,
    dashOffset: 0,
    translateX: 0,
  );
}

/// thinking — dashed flow R→L (3000ms linear).
_TideFrame _frameFlow(KaiTideState s, double t, KaiTokens tokens) {
  return _TideFrame(
    strokeWidth: 2.0,
    opacity: 0.85,
    useGradient: true,
    solidColor: tokens.colors.ink4,
    dashPattern: const [6, 4],
    dashOffset: -40 * t,
    translateX: 0,
  );
}

/// responding — dashed stream R→L (1400ms linear).
_TideFrame _frameStream(KaiTideState s, double t, KaiTokens tokens) {
  return _TideFrame(
    strokeWidth: 2.5,
    opacity: 1.0,
    useGradient: true,
    solidColor: tokens.colors.ink4,
    dashPattern: const [12, 4],
    dashOffset: -32 * t,
    translateX: 0,
  );
}

/// success — flash. Piecewise over 1200ms cycle, ease-out per .p-success canon.
/// CSS: `animation: tide-flash 1.2s ease-out 3;`
/// Keyframes: 0%→stroke1.5/op0.3, 25%→stroke3.2/op1.0, 65%→stroke2.5/op1.0,
///            100%→stroke2.0/op0.85.
/// easeOut applied to each segment's local t so the deceleration maps faithfully.
_TideFrame _frameFlash(KaiTideState s, double t, KaiTokens tokens) {
  double sw;
  double op;
  if (t < 0.25) {
    final u = Curves.easeOut.transform(t / 0.25);
    sw = _lerp(1.5, 3.2, u);
    op = _lerp(0.3, 1.0, u);
  } else if (t < 0.65) {
    // hold segment 0.25–0.65: both values steady at peak
    final u = Curves.easeOut.transform((t - 0.25) / 0.40);
    sw = _lerp(3.2, 2.5, u);
    op = 1.0;
  } else {
    final u = Curves.easeOut.transform((t - 0.65) / 0.35);
    sw = _lerp(2.5, 2.0, u);
    op = _lerp(1.0, 0.85, u);
  }
  return _TideFrame(
    strokeWidth: sw,
    opacity: op,
    useGradient: true,
    solidColor: tokens.colors.positive,
    dashPattern: null,
    dashOffset: 0,
    translateX: 0,
  );
}

/// error — wobble translateX over 700ms.
_TideFrame _frameWobble(KaiTideState s, double t, KaiTokens tokens) {
  // 0→-6→+6→-4→+4→0 control points across 700ms cycle.
  // Implement as a piecewise linear path through five waypoints.
  const stops = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0];
  const offsets = [0.0, -6.0, 6.0, -4.0, 4.0, 0.0];
  double translate = 0;
  for (var i = 0; i < stops.length - 1; i++) {
    if (t >= stops[i] && t <= stops[i + 1]) {
      final u = (t - stops[i]) / (stops[i + 1] - stops[i]);
      translate = _lerp(offsets[i], offsets[i + 1], u);
      break;
    }
  }
  return _TideFrame(
    strokeWidth: 2.0,
    opacity: 0.95,
    useGradient: false,
    solidColor: tokens.colors.negative,
    dashPattern: null,
    dashOffset: 0,
    translateX: translate,
  );
}

/// memory — pop scale-up + scale-down 900ms.
_TideFrame _framePop(KaiTideState s, double t, KaiTokens tokens) {
  double sw;
  double op;
  if (t < 0.5) {
    final u = t / 0.5;
    sw = _lerp(1.8, 4.0, u);
    op = _lerp(0.6, 1.0, u);
  } else {
    final u = (t - 0.5) / 0.5;
    sw = _lerp(4.0, 2.0, u);
    op = 1.0;
  }
  return _TideFrame(
    strokeWidth: sw,
    opacity: op,
    useGradient: true,
    solidColor: tokens.colors.ink4,
    dashPattern: null,
    dashOffset: 0,
    translateX: 0,
  );
}

class _TidePainter extends CustomPainter {
  _TidePainter({required this.frame});

  final _TideFrame frame;

  @override
  void paint(Canvas canvas, Size size) {
    final basePath = _buildPath(size);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = frame.strokeWidth
      ..isAntiAlias = true;

    if (frame.useGradient) {
      paint.shader = KaiTide.gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    } else {
      paint.color = frame.solidColor;
    }

    // Apply opacity via Paint.color alpha multiplier; works for both
    // shader and solid because we layer the canvas paint in a save-layer
    // (cheaper alternative: ignore alpha multiplication on shader and
    // accept full alpha — but here we use saveLayer for correctness when
    // opacity < 1).
    if (frame.opacity < 1.0) {
      final alpha = (frame.opacity * 255).round().clamp(0, 255);
      canvas.saveLayer(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Color.fromARGB(alpha, 255, 255, 255),
      );
    }

    final path = frame.dashPattern == null
        ? basePath
        : _dashedPath(
            basePath,
            frame.dashPattern![0],
            frame.dashPattern![1],
            frame.dashOffset,
          );
    canvas.drawPath(path, paint);

    if (frame.opacity < 1.0) {
      canvas.restore();
    }
  }

  Path _buildPath(Size size) {
    final p = Path();
    final sx = size.width / 240.0;
    final sy = size.height / 28.0;
    p.moveTo(0, 14 * sy);
    p.quadraticBezierTo(60 * sx, 8 * sy, 120 * sx, 14 * sy);
    // Reflected Q: prev control (60,8) reflected across endpoint (120,14)
    //   -> (2*120-60, 2*14-8) = (180, 20)
    p.quadraticBezierTo(180 * sx, 20 * sy, 240 * sx, 12 * sy);
    return p;
  }

  Path _dashedPath(Path src, double dashOn, double dashOff, double startOffset) {
    final result = Path();
    final stride = dashOn + dashOff;
    for (final metric in src.computeMetrics()) {
      // Normalise startOffset into [0, stride). Then start at -phase so
      // negative offsets advance dashes leftward visually but extract
      // forward along the metric.
      var phase = startOffset % stride;
      if (phase < 0) phase += stride;
      var t = -phase;
      while (t < metric.length) {
        final start = math.max<double>(t, 0);
        final end = math.min<double>(t + dashOn, metric.length);
        if (end > start) {
          result.addPath(metric.extractPath(start, end), ui.Offset.zero);
        }
        t += stride;
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant _TidePainter old) =>
      old.frame.strokeWidth != frame.strokeWidth ||
      old.frame.opacity != frame.opacity ||
      old.frame.useGradient != frame.useGradient ||
      old.frame.solidColor != frame.solidColor ||
      old.frame.dashOffset != frame.dashOffset ||
      old.frame.translateX != frame.translateX ||
      !_dashEq(old.frame.dashPattern, frame.dashPattern);

  static bool _dashEq(List<double>? a, List<double>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
