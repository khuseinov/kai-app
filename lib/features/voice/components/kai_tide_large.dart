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

    final t = animationValue * 2.0 * math.pi;

    // Gradients matching voice.html definitions
    final gMute = ui.Gradient.linear(
      Offset.zero,
      Offset(size.width, 0),
      [
        const Color(0xFF5C5C58),
        const Color(0xFF76767E),
      ],
      [0.0, 1.0],
    );

    final gBlue = ui.Gradient.linear(
      Offset.zero,
      Offset(size.width, 0),
      [
        const Color(0xFF1B4FB0),
        const Color(0xFF6FA7FF),
      ],
      [0.0, 1.0],
    );

    final gWarm = ui.Gradient.linear(
      Offset.zero,
      Offset(size.width, 0),
      [
        const Color(0xFF2BA8C9),
        const Color(0xFFF4B589),
      ],
      [0.0, 1.0],
    );

    switch (state) {
      case KaiTideLargeState.idle:
        // Idle: stroke-width: 2.5, opacity: 0.45, stroke: url(#g-mute)
        strokeWidth = 2.5;
        opacity = 0.45;
        paint.shader = gMute;
        break;

      case KaiTideLargeState.listening:
        // Listening: stroke-width: 3.0, opacity: 1.0, stroke: url(#g-blue)
        strokeWidth = 3.0;
        opacity = 1.0;
        paint.shader = gBlue;
        break;

      case KaiTideLargeState.speaking:
        // Speaking: stroke-width: 3.5, opacity: 1.0, stroke: url(#g-warm), stroke-dasharray: 16 5
        strokeWidth = 3.5;
        opacity = 1.0;
        paint.shader = gWarm;

        dashPattern = const [16.0, 5.0];
        // Animate stroke-dashoffset from 0 to -42 over 2.6s (loop period is 6s)
        dashOffset = animationValue * (-42.0 / 2.6) * 6.0;
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

    if (state == KaiTideLargeState.idle) {
      // Idle state path: M 6 56 Q 50 38, 100 56 T 200 56 T 314 46
      final yStart = 56.0 * sy;
      final yCtrl1 = 38.0 * sy;
      final yEnd1 = 56.0 * sy;
      final yEnd2 = 56.0 * sy;
      final yEnd3 = 46.0 * sy;

      p.moveTo(6 * sx, yStart);
      p.quadraticBezierTo(50 * sx, yCtrl1, 100 * sx, yEnd1);
      final yCtrl2 = 2.0 * yEnd1 - yCtrl1;
      p.quadraticBezierTo(150 * sx, yCtrl2, 200 * sx, yEnd2);
      final yCtrl3 = 2.0 * yEnd2 - yCtrl2;
      p.quadraticBezierTo(250 * sx, yCtrl3, 314 * sx, yEnd3);
    } else if (state == KaiTideLargeState.listening) {
      // Listening state path: interpolates between Path 1 and Path 2 dynamically
      // u: 0.0 -> 1.0 -> 0.0
      // Path 1: M 6 56 Q 50 24, 100 56 T 200 56 T 314 40
      // Path 2: M 6 54 Q 50 72, 100 54 T 200 48 T 314 60
      final u = (math.sin(t) + 1.0) / 2.0;

      final yStart = (56.0 + (54.0 - 56.0) * u) * sy;
      final yCtrl1 = (24.0 + (72.0 - 24.0) * u) * sy;
      final yEnd1 = (56.0 + (54.0 - 56.0) * u) * sy;
      final yEnd2 = (56.0 + (48.0 - 56.0) * u) * sy;
      final yEnd3 = (40.0 + (60.0 - 40.0) * u) * sy;

      p.moveTo(6 * sx, yStart);
      p.quadraticBezierTo(50 * sx, yCtrl1, 100 * sx, yEnd1);
      final yCtrl2 = 2.0 * yEnd1 - yCtrl1;
      p.quadraticBezierTo(150 * sx, yCtrl2, 200 * sx, yEnd2);
      final yCtrl3 = 2.0 * yEnd2 - yCtrl2;
      p.quadraticBezierTo(250 * sx, yCtrl3, 314 * sx, yEnd3);
    } else {
      // Speaking state path (Responding): static M 6 56 Q 50 24, 100 56 T 200 56 T 314 40
      final yStart = 56.0 * sy;
      final yCtrl1 = 24.0 * sy;
      final yEnd1 = 56.0 * sy;
      final yEnd2 = 56.0 * sy;
      final yEnd3 = 40.0 * sy;

      p.moveTo(6 * sx, yStart);
      p.quadraticBezierTo(50 * sx, yCtrl1, 100 * sx, yEnd1);
      final yCtrl2 = 2.0 * yEnd1 - yCtrl1;
      p.quadraticBezierTo(150 * sx, yCtrl2, 200 * sx, yEnd2);
      final yCtrl3 = 2.0 * yEnd2 - yCtrl2;
      p.quadraticBezierTo(250 * sx, yCtrl3, 314 * sx, yEnd3);
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
