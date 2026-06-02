import 'package:flutter/material.dart';

import '../tokens/kai_tokens.dart';

/// Renders the canonical brand curve inside a given size.
///
/// Under the hood, this uses a scaled CustomPainter wrapping the official path:
/// `M 2 8 Q 9 2, 18 8 T 34 5` (viewBox width=36, height=14).
class KaiBrandCurve extends StatelessWidget {
  const KaiBrandCurve({
    this.width = 36,
    this.height = 14,
    this.color = Colors.white,
    this.strokeWidth = 2.5,
    super.key,
  });

  final double width;
  final double height;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _KaiBrandCurvePainter(color: color, strokeWidth: strokeWidth),
    );
  }
}

/// The main brand logo mark: a square corner-gradient surface containing
/// the centered brand curve.
class KaiLogo extends StatelessWidget {
  const KaiLogo({
    this.size = 64,
    super.key,
  });

  /// The dimension (width and height) of the square logo.
  final double size;

  @override
  Widget build(BuildContext context) {
    // Keep proportions matching canon:
    // For size 64: curve is 36×14, radius is 20.
    final curveW = size * (36.0 / 64.0);
    final curveH = size * (14.0 / 64.0);
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
      ),
    );
  }
}

class _KaiBrandCurvePainter extends CustomPainter {
  const _KaiBrandCurvePainter({
    required this.color,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth
      ..color = color;

    final sx = size.width / 36.0;
    final sy = size.height / 14.0;

    final path = Path()
      ..moveTo(2.0 * sx, 8.0 * sy)
      ..quadraticBezierTo(9.0 * sx, 2.0 * sy, 18.0 * sx, 8.0 * sy)
      // Reflected Q: control (9,2) reflected across (18,8) → (27,14)
      ..quadraticBezierTo(27.0 * sx, 14.0 * sy, 34.0 * sx, 5.0 * sy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _KaiBrandCurvePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
