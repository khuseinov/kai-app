import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/theme_extensions.dart';

enum KaiVoiceState { idle, listening, thinking, speaking }

class KaiGeminiWave extends StatefulWidget {
  final Widget child;
  final KaiVoiceState state;

  const KaiGeminiWave({
    super.key,
    required this.child,
    this.state = KaiVoiceState.idle,
  });

  @override
  State<KaiGeminiWave> createState() => _KaiGeminiWaveState();
}

class _KaiGeminiWaveState extends State<KaiGeminiWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
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
    final isVisible = widget.state != KaiVoiceState.idle;

    // Use the 4 brand colors for the Gemini effect
    final waveColors = [
      colors.oceanPrimary, // Blue
      colors.stateListening, // Cyan
      colors.stateThinking, // Violet
      colors.stateSpeaking, // Teal
    ];

    return Stack(
      children: [
        widget.child,
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 120, // Give enough height for the glow to bleed upwards
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _GeminiWavePainter(
                      animationValue: _controller.value,
                      colors: waveColors,
                    ),
                    size: const Size.fromHeight(120),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GeminiWavePainter extends CustomPainter {
  final double animationValue;
  final List<Color> colors;

  _GeminiWavePainter({required this.animationValue, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final height = size.height;
    final width = size.width;

    // We draw 4 intersecting, flattened ovals along the bottom edge.
    // They shift left/right and up/down based on the animation value.
    final t = animationValue * 2 * math.pi;

    final blobWidth = width * 0.8;
    final blobHeight = height * 0.6; // Base height of the blobs
    const blurFilter = MaskFilter.blur(BlurStyle.normal, 40.0);

    for (var i = 0; i < colors.length; i++) {
      // Offset each blob's phase so they move out of sync
      final phaseOffset = (i * math.pi / 2);

      // Calculate center position for each blob
      // Move horizontally back and forth
      final cx = (width / 2) + math.sin(t + phaseOffset) * (width * 0.4);
      // Move vertically slightly to create a wave effect
      final cy =
          height - (blobHeight / 3) + math.cos(t * 1.5 + phaseOffset) * 20;

      final paint = Paint()
        ..color = colors[i].withValues(
            alpha: 0.7) // Solid alpha, no BlendMode.screen for web stability
        ..maskFilter = blurFilter;

      final rect = Rect.fromCenter(
        center: Offset(cx, cy),
        width: blobWidth,
        height: blobHeight,
      );

      canvas.drawOval(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GeminiWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
