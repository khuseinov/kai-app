import 'package:flutter/material.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/l10n/app_localizations.dart';

class VoiceControlHints extends StatelessWidget {
  const VoiceControlHints({
    required this.visible,
    required this.onTapTranscript,
    super.key,
  });

  final bool visible;
  final VoidCallback onTapTranscript;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = KaiTheme.of(context).colors;
    final hintColor = isDark ? const Color(0x40FFFFFF) : c.ink3;
    final loc = AppLocalizations.of(context);

    return Stack(
      children: [
        Positioned(
          top: 12,
          left: 54,
          child: Text(
            loc.voiceHintTapToSpeak,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 9,
              color: hintColor,
              letterSpacing: 0.12,
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 18,
          child: GestureDetector(
            onTap: onTapTranscript,
            child: Text(
              loc.voiceHintSwipeTranscript,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 9,
                color: hintColor,
                letterSpacing: 0.12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
