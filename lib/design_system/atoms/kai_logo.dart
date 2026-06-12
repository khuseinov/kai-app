import 'package:flutter/material.dart';

import '../tokens/kai_tokens.dart';

/// Renders the canonical brand curve inside a given size.
///
/// Splash-glyph canon from `brand.html` / `brand/splash-glyph.svg`:
/// viewBox 36×18, path `M 2 11 Q 9 3, 18 11 T 34 7`, stroke-width 2.5.
///
/// [progress] controls stroke-draw animation: 0 = empty, 1 = full curve.
class KaiBrandCurve extends StatelessWidget {
  const KaiBrandCurve({
    this.width = 36,
    this.height = 18,
    this.color = Colors.white,
    this.strokeWidth = 2.5,
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
    // Keep proportions matching canon (brand.html splash glyph):
    // For size 64: curve viewBox is 36×18, radius is 20.
    final curveW = size * (36.0 / 64.0);
    final curveH = size * (18.0 / 64.0);
    final radius = size * (20.0 / 64.0);

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

  Path _curvePath(Size size) {
    final sx = size.width / 36.0;
    final sy = size.height / 18.0;

    return Path()
      ..moveTo(2.0 * sx, 11.0 * sy)
      ..quadraticBezierTo(9.0 * sx, 3.0 * sy, 18.0 * sx, 11.0 * sy)
      // Reflected Q: control (9,3) reflected across (18,11) → (27,19)
      ..quadraticBezierTo(27.0 * sx, 19.0 * sy, 34.0 * sx, 7.0 * sy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _curvePath(size);
    final metrics = path.computeMetrics();
    final metricsIterator = metrics.iterator;
    if (!metricsIterator.moveNext()) {
      // Fallback: draw the full path if metrics are unavailable.
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = strokeWidth
        ..color = color;
      canvas.drawPath(path, paint);
      return;
    }
    final metric = metricsIterator.current;

    final drawLength = metric.length * progress.clamp(0.0, 1.0);
    final drawnPath = metric.extractPath(0, drawLength);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth
      ..color = color;

    canvas.drawPath(drawnPath, paint);
  }

  @override
  bool shouldRepaint(covariant _KaiBrandCurvePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.progress != progress;
  }
}
