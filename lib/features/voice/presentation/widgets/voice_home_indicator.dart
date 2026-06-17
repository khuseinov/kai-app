import 'package:flutter/material.dart';

class VoiceHomeIndicator extends StatelessWidget {
  const VoiceHomeIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Container(
          width: 76,
          height: 3,
          decoration: BoxDecoration(
            color: const Color(0x66FFFFFF),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}
