import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../design_system/theme/kai_theme.dart';
import '../../../design_system/tokens/kai_tokens.dart';

/// Display states for [KaiTideLarge].
enum KaiTideLargeState {
  /// Thin gray static wave with low amplitude.
  idle,

  /// Active animated cyan/blue wave representing recording.
  listening,

  /// Animated dashed warm wave representing Kai response.
  speaking,
}

/// A large animated tide curve widget for voice-mode.
///
/// Designed to render a fluid organic wave that changes structure, thickness,
/// and style based on the active [KaiTideLargeState].
///
/// Self-animating internally. Handles the wave phase transitions and dash shifts.
class KaiTideLarge extends StatefulWidget {
  const KaiTideLarge({
    required this.state,
    this.height = 100,
    super.key,
  });

  /// The active display state of the wave.
  final KaiTideLargeState state;

  /// Height constraints. Matches HTML's 100px large tide container.
  final double height;

  @override
  State<KaiTideLarge> createState() => _KaiTideLargeState();
}

class _KaiTideLargeState extends State<KaiTideLarge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6), // Looping animation duration
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);

    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _LargeTidePainter(
              state: widget.state,
              animationValue: _controller.value,
              tokens: tokens,
            ),
          );
        },
      ),
    );
  }
}

class _LargeTidePainter extends CustomPainter {
  _LargeTidePainter({
    required this.state,
    required this.animationValue,
    required this.tokens,
  });

  final KaiTideLargeState state;
  final double animationValue;
  final KaiTokens tokens;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 320.0;
    final sy = size.height / 100.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    double strokeWidth;
    double opacity;
    List<double>? dashPattern;
    double dashOffset = 0;

    // We overlay multiple sine wave cycles or dynamic Q curves.
    // For listening/speaking, we add an offset factor driven by `animationValue`.
    final t = animationValue * 2.0 * math.pi;

    switch (state) {
      case KaiTideLargeState.idle:
        strokeWidth = 2.5;
        opacity = 0.45;
        paint.color = tokens.colors.ink4;
        break;

      case KaiTideLargeState.listening:
        strokeWidth = 3.0;
        opacity = 1.0;
        // Warm cyan/blue gradient for listening
        paint.shader = ui.Gradient.linear(
          Offset.zero,
          Offset(size.width, 0),
          [
            tokens.colors.accent,
            tokens.colors.accentLine,
          ],
        );
        break;

      case KaiTideLargeState.speaking:
        strokeWidth = 3.5;
        opacity = 1.0;
        // Warm orange/tide gradient for speaking
        paint.shader = KaiTide.gradient.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        );
        dashPattern = const [16.0, 5.0];
        // Dash flow: shift offset in reverse over time
        final stride = dashPattern[0] + dashPattern[1];
        dashOffset = -animationValue * stride * 8.0; // flow factor
        break;
    }

    paint.strokeWidth = strokeWidth;

    if (opacity < 1.0) {
      final alpha = (opacity * 255).round().clamp(0, 255);
      canvas.saveLayer(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Color.fromARGB(alpha, 255, 255, 255),
      );
    }

    final basePath = _buildPath(size, sx, sy, t);

    final path = dashPattern == null
        ? basePath
        : _dashedPath(basePath, dashPattern[0], dashPattern[1], dashOffset);

    canvas.drawPath(path, paint);

    if (opacity < 1.0) {
      canvas.restore();
    }
  }

  Path _buildPath(Size size, double sx, double sy, double t) {
    final p = Path();

    // Base coordinate anchors from HTML canon: M 6 56 Q 50 24...
    // We add sine perturbation to the control points to create organic waving.
    final startY = 56 * sy;
    p.moveTo(6 * sx, startY);

    if (state == KaiTideLargeState.idle) {
      // Static wave, low amplitude, no animations
      p.quadraticBezierTo(
        50 * sx,
        38 * sy,
        100 * sx,
        56 * sy,
      );
      p.quadraticBezierTo(
        150 * sx,
        56 * sy,
        200 * sx,
        56 * sy,
      );
      p.quadraticBezierTo(
        257 * sx,
        51 * sy,
        314 * sx,
        46 * sy,
      );
    } else if (state == KaiTideLargeState.listening) {
      // Dynamic blue wave, medium amplitude
      final dy = math.sin(t * 1.0) * 10 * sy;
      final dy2 = math.cos(t * 1.5) * 8 * sy;
      p.quadraticBezierTo(
        50 * sx,
        (24 + dy) * sy,
        100 * sx,
        (56 + dy2) * sy,
      );
      p.quadraticBezierTo(
        150 * sx,
        (56 - dy2) * sy,
        200 * sx,
        (56 + dy) * sy,
      );
      p.quadraticBezierTo(
        257 * sx,
        (40 - dy) * sy,
        314 * sx,
        40 * sy,
      );
    } else {
      // Dynamic warm speaking wave, higher amplitude
      final dy = math.sin(t * 2.0) * 14 * sy;
      final dy2 = math.cos(t * 1.8) * 11 * sy;
      p.quadraticBezierTo(
        50 * sx,
        (20 + dy) * sy,
        100 * sx,
        (56 + dy2) * sy,
      );
      p.quadraticBezierTo(
        150 * sx,
        (56 - dy2) * sy,
        200 * sx,
        (56 + dy) * sy,
      );
      p.quadraticBezierTo(
        257 * sx,
        (38 - dy) * sy,
        314 * sx,
        40 * sy,
      );
    }

    return p;
  }

  Path _dashedPath(Path src, double dashOn, double dashOff, double startOffset) {
    final result = Path();
    final stride = dashOn + dashOff;
    for (final metric in src.computeMetrics()) {
      var phase = startOffset % stride;
      if (phase < 0) phase += stride;
      var t = -phase;
      while (t < metric.length) {
        final start = math.max<double>(t, 0);
        final end = math.min<double>(t + dashOn, metric.length);
        if (end > start) {
          result.addPath(metric.extractPath(start, end), Offset.zero);
        }
        t += stride;
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant _LargeTidePainter old) =>
      old.state != state ||
      old.animationValue != animationValue ||
      old.tokens != tokens;
}
