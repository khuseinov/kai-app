import 'package:flutter/material.dart';

class VoiceNotchIsland extends StatelessWidget {
  const VoiceNotchIsland({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          width: 76,
          height: 22,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}
