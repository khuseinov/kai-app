import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kai_app/design_system/primitives/primitives.dart';

class VoiceCloseButton extends StatelessWidget {
  const VoiceCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: 18,
      child: GestureDetector(
        onTap: () => context.go('/room'),
        child: Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0x1AFFFFFF),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const KaiIcon(
            KaiIconName.close,
            size: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
