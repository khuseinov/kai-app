import 'package:flutter/material.dart';
import 'package:kai_app/design_system/atoms/atoms.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
import 'package:kai_app/features/voice/presentation/widgets/kai_transcript_view.dart';

class VoiceTranscriptSheet extends StatelessWidget {
  const VoiceTranscriptSheet({
    required this.events,
    required this.onReturn,
    super.key,
  });

  final List<KaiTranscriptEvent> events;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = KaiTheme.of(context).colors;
    final textColor = isDark ? const Color(0x66FFFFFF) : c.ink3;
    final dividerColor = isDark ? const Color(0x0FFFFFFF) : c.line;

    return Stack(
      key: const ValueKey<String>('transcript_view'),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header row with sub-wave
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 56,
                    height: 8,
                    child: KaiTideCurve(
                      state: KaiTide.muted,
                      height: 8,
                    ),
                  ),
                  Text(
                    'сегодня · 12:34',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: dividerColor),
            
            // Scrollable Timeline
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  if (notification is ScrollUpdateNotification) {
                    final metrics = notification.metrics;
                    if (metrics.pixels <= 0) {
                      final dragDeltaY = notification.dragDetails?.delta.dy ?? 0;
                      final scrollDelta = notification.scrollDelta ?? 0;
                      if (dragDeltaY > 0 || scrollDelta < 0) {
                        onReturn();
                      }
                    }
                  } else if (notification is OverscrollNotification) {
                    if (notification.overscroll < 0) {
                      onReturn();
                    }
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 8, bottom: 76),
                  child: KaiTranscriptView(events: events),
                ),
              ),
            ),
          ],
        ),

        // Bottom Return action button
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 26),
            child: GestureDetector(
              onTap: onReturn,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Colors.transparent,
                child: Text(
                  'СВАЙП ↑ · ВЕРНУТЬСЯ К ГОЛОСУ',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    letterSpacing: 0.14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
