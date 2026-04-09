import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design/theme/theme_extensions.dart';

import '../../../core/design/components/kai_hologram.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  KaiHologramState _hologramState = KaiHologramState.idle;

  void _handleTap() {
    setState(() {
      // Toggle between idle and listening for demonstration
      if (_hologramState == KaiHologramState.idle) {
        _hologramState = KaiHologramState.listening;
      } else {
        _hologramState = KaiHologramState.idle;
      }
    });

    // TODO: Hook into real speech-to-text here
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;
    final isListening = _hologramState == KaiHologramState.listening;

    return Scaffold(
      backgroundColor: colors.background,
      body: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Holographic Entity
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: KaiHologram(state: _hologramState),
              ),
            ),
            
            // Minimal text prompt
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 60.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      isListening ? 'Слушаю...' : 'Коснитесь любой точки, чтобы разбудить',
                      key: ValueKey<bool>(isListening),
                      style: typography.titleLarge.copyWith(
                        color: isListening ? colors.stateListening : colors.textTertiary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

