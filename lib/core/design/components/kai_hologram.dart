import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/theme_extensions.dart';

/// State of the Hologram to determine colors and animation speed
enum KaiHologramState {
  idle,
  listening,
  thinking,
  speaking,
}

class KaiHologram extends StatefulWidget {
  final KaiHologramState state;

  const KaiHologram({
    super.key,
    this.state = KaiHologramState.idle,
  });

  @override
  State<KaiHologram> createState() => _KaiHologramState();
}

class _KaiHologramState extends State<KaiHologram> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;

    Color primaryColor;
    Color secondaryColor;
    Color tertiaryColor;
    
    switch (widget.state) {
      case KaiHologramState.idle:
        primaryColor = Colors.transparent;
        secondaryColor = Colors.transparent;
        tertiaryColor = Colors.transparent;
        break;
      case KaiHologramState.listening:
        primaryColor = colors.stateListening; // Cyan
        secondaryColor = colors.stateThinking; // Violet
        tertiaryColor = colors.stateSpeaking; // Teal
        break;
      case KaiHologramState.thinking:
        primaryColor = colors.stateThinking;
        secondaryColor = colors.stateThinking.withValues(alpha: 0.5);
        tertiaryColor = colors.stateListening;
        break;
      case KaiHologramState.speaking:
        primaryColor = colors.stateSpeaking;
        secondaryColor = colors.stateListening;
        tertiaryColor = colors.stateThinking;
        break;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _GoogleAuraPainter(
            animationValue: _controller.value,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            tertiaryColor: tertiaryColor,
            state: widget.state,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _GoogleAuraPainter extends CustomPainter {
  final double animationValue;
  final Color primaryColor;
  final Color secondaryColor;
  final Color tertiaryColor;
  final KaiHologramState state;

  _GoogleAuraPainter({
    required this.animationValue,
    required this.primaryColor,
    required this.secondaryColor,
    required this.tertiaryColor,
    required this.state,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (state == KaiHologramState.idle) return; // Keep pure canvas in idle mode

    final time = animationValue * 2 * math.pi;
    final width = size.width;
    final height = size.height;
    
    // Soft full screen base glow
    final basePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), basePaint);

    // Draw large, deeply blurred moving blobs resembling Google Gemini/Assistant voice UI
    _drawBlob(
      canvas,
      width * 0.3 + math.sin(time) * 40,
      height * 0.7 + math.cos(time * 0.8) * 40,
      width * 0.8,
      primaryColor.withValues(alpha: 0.5),
    );

    _drawBlob(
      canvas,
      width * 0.7 + math.cos(time * 1.2) * 50,
      height * 0.8 + math.sin(time * 1.5) * 40,
      width * 0.7,
      secondaryColor.withValues(alpha: 0.5),
    );

    _drawBlob(
      canvas,
      width * 0.5 + math.sin(time * 0.5) * 60,
      height * 0.9 + math.cos(time * 1.1) * 30,
      width * 0.9,
      tertiaryColor.withValues(alpha: 0.5),
    );
  }

  void _drawBlob(Canvas canvas, double x, double y, double radius, Color color) {
    // Extreme blur for "liquid aura" effect
    final paint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);

    // Draw an elliptical/distorted shape to look more organic than a perfect circle
    final rect = Rect.fromCenter(
      center: Offset(x, y),
      width: radius * 1.2,
      height: radius * 0.8,
    );
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _GoogleAuraPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.state != state;
  }
}
