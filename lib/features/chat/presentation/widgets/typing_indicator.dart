import 'package:flutter/material.dart';

import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_radii.dart';
import '../../../../core/design/tokens/kai_spacing.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: KaiSpacing.m,
          vertical: KaiSpacing.s,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(KaiRadii.lRaw),
            topRight: Radius.circular(KaiRadii.lRaw),
            bottomLeft: Radius.circular(KaiSpacing.xxs),
            bottomRight: Radius.circular(KaiRadii.lRaw),
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                // Stagger each dot by 0.3 seconds (200ms offset)
                final offset = index * 0.2;
                // Each dot fades in and out over its portion of the cycle
                final t = (_controller.value - offset) % 1.0;
                final opacity = (t < 0.5)
                    ? (t / 0.5).clamp(0.0, 1.0)
                    : (1.0 - (t - 0.5) / 0.5).clamp(0.0, 1.0);

                return Padding(
                  padding: EdgeInsets.only(
                    right: index < 2 ? KaiSpacing.xxs : 0,
                  ),
                  child: Opacity(
                    opacity: opacity.clamp(0.15, 1.0),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.textTertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
