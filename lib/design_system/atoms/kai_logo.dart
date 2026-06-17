import 'package:flutter/material.dart';

import 'package:kai_app/design_system/tokens/kai_tokens.dart';

/// Renders the canonical brand curve inside a given size.
///
/// Brand curve canon from `brand.html` / app icon:
/// viewBox 60×16, path `M 2 10 Q 14 2, 28 10 T 56 6`, stroke-width 3.
///
/// [progress] controls stroke-draw animation: 0 = empty, 1 = full curve.
class KaiBrandCurve extends StatelessWidget {
  const KaiBrandCurve({
    this.width = 60,
    this.height = 16,
    this.color = Colors.white,
    this.strokeWidth = 3.0,
    this.progress = 1.0,
    super.key,
  });

  final double width;
  final double height;
  final Color color;
  final double strokeWidth;

  /// Stroke-draw progress in the range [0, 1].
  final double progress;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _KaiBrandCurvePainter(
        color: color,
        strokeWidth: strokeWidth,
        progress: progress,
      ),
    );
  }
}

/// The main brand logo mark: a square corner-gradient surface containing
/// the centered brand curve.
class KaiLogo extends StatelessWidget {
  const KaiLogo({
    this.size = 64,
    this.curveProgress = 1.0,
    super.key,
  });

  /// The dimension (width and height) of the square logo.
  final double size;

  /// Stroke-draw progress of the inner brand curve in the range [0, 1].
  /// Defaults to 1.0 (fully drawn).
  final double curveProgress;

  @override
  Widget build(BuildContext context) {
    // ponytail: follow iOS-standard 22% radius and proportions from brand.html
    // App Icon. Curve area matches CSS inset: 22% 16% 24% → 68% width, 54% height.
    // stroke-width 3 is in viewBox units — the painter applies non-uniform
    // canvas.scale to replicate SVG preserveAspectRatio="none" (fat wave).
    final curveW = size * 0.68;
    final curveH = size * 0.54;
    final radius = size * 0.22;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: KaiTide.gradientCorner,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
      alignment: Alignment.center,
      child: KaiBrandCurve(
        width: curveW,
        height: curveH,
        progress: curveProgress,
      ),
    );
  }
}

class _KaiBrandCurvePainter extends CustomPainter {
  const _KaiBrandCurvePainter({
    required this.color,
    required this.strokeWidth,
    required this.progress,
  });

  final Color color;
  final double strokeWidth;
  final double progress;

  // ponytail: viewBox 60×16, same as brand.html app-icon SVG
  static const double _vbW = 60;
  static const double _vbH = 16;

  /// Build path in original viewBox coordinates (60×16).
  Path _curvePath() {
    return Path()
      ..moveTo(2, 10)
      ..quadraticBezierTo(14, 2, 28, 10)
      // T 56 6 → reflected control = (2*28-14, 2*10-2) = (42, 18)
      ..quadraticBezierTo(42, 18, 56, 6);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // ponytail: replicate SVG preserveAspectRatio="none" — non-uniform scale
    // so the stroke gets stretched vertically, producing the fat wave from
    // brand.html app icon. strokeWidth is in viewBox units (default 3).
    final sx = size.width / _vbW;
    final sy = size.height / _vbH;

    canvas.save();
    canvas.scale(sx, sy);

    final fullPath = _curvePath();

    Path drawPath;
    if (progress >= 1.0) {
      drawPath = fullPath;
    } else {
      final metrics = fullPath.computeMetrics();
      final metricsIterator = metrics.iterator;
      if (!metricsIterator.moveNext()) {
        drawPath = fullPath;
      } else {
        final metric = metricsIterator.current;
        final drawLength = metric.length * progress.clamp(0.0, 1.0);
        drawPath = metric.extractPath(0, drawLength);
      }
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth
      ..color = color;

    canvas.drawPath(drawPath, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _KaiBrandCurvePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.progress != progress;
  }
}
