import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kai_app/design_system/primitives/primitives.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';

class VoiceCloseButton extends StatelessWidget {
  const VoiceCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = KaiTheme.of(context).colors;

    return Positioned(
      top: 8,
      left: 18,
      child: GestureDetector(
        onTap: () => context.go('/room'),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDark ? const Color(0x1AFFFFFF) : c.surface2,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: KaiIcon(
            KaiIconName.close,
            size: 14,
            color: isDark ? Colors.white : c.ink1,
          ),
        ),
      ),
    );
  }
}
