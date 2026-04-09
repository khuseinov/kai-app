import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/theme_extensions.dart';

enum KaiAgentState { idle, listening, thinking, speaking }

/// A new abstract 3D/Particle visualizer replacing the classic Orb
class Kai3DVisualizer extends StatefulWidget {
  final KaiAgentState state;
  final double size;

  const Kai3DVisualizer({
    super.key,
    this.state = KaiAgentState.idle,
    this.size = 150.0,
  });

  @override
  State<Kai3DVisualizer> createState() => _Kai3DVisualizerState();
}

class _Kai3DVisualizerState extends State<Kai3DVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    
    Color activeColor;
    switch (widget.state) {
      case KaiAgentState.idle:
        activeColor = colors.textSecondary.withOpacity(0.5);
        break;
      case KaiAgentState.listening:
        activeColor = colors.stateListening;
        break;
      case KaiAgentState.thinking:
        activeColor = colors.stateThinking;
        break;
      case KaiAgentState.speaking:
        activeColor = colors.stateSpeaking;
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _AbstractParticlePainter(
              progress: _controller.value,
              color: activeColor,
              state: widget.state,
            ),
          );
        },
      ),
    );
  }
}

class _AbstractParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  final KaiAgentState state;

  _AbstractParticlePainter({
    required this.progress,
    required this.color,
    required this.state,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final maxRadius = size.width / 2;
    int lines = state == KaiAgentState.thinking ? 12 : 8;
    
    // Draw abstract rotating sine waves/particles
    for (int i = 0; i < lines; i++) {
      final angle = (i * 2 * math.pi / lines) + (progress * 2 * math.pi * (i % 2 == 0 ? 1 : -1));
      final amplitude = state == KaiAgentState.speaking ? 20.0 : (state == KaiAgentState.listening ? 10.0 : 5.0);
      
      final path = Path();
      path.moveTo(center.dx, center.dy);
      
      for (double r = 0; r <= maxRadius; r += 5) {
        final currentAngle = angle + math.sin(r * 0.1 - progress * 10) * (amplitude / maxRadius);
        final x = center.dx + r * math.cos(currentAngle);
        final y = center.dy + r * math.sin(currentAngle);
        if (r == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      paint.color = color.withOpacity((1.0 - (1.0 / lines) * i).clamp(0.1, 1.0));
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AbstractParticlePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color || oldDelegate.state != state;
  }
}
