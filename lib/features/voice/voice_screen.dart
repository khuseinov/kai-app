import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/atoms/atoms.dart';
import '../../design_system/tokens/kai_tokens.dart';
import 'components/kai_karaoke_text.dart';
import 'components/kai_tide_large.dart';
import 'components/kai_transcript_view.dart';

/// The internal states of the [VoiceScreen] flow.
enum _VoiceState {
  /// Waiting for user input. Gray static wave.
  idle,

  /// Active listening to user voice. Shifting blue wave.
  listening,

  /// Speaking response. Shifting warm dashed wave + karaoke text.
  speaking,

  /// Reviewing dialog history timeline.
  transcript,
}

/// Voice screen component matching `voice.html` specs.
///
/// Designed to run in a dark-only container (#08080A) with gesture-invoked
/// actions and animated waves. Uses mock logic to simulate speech-to-text
/// and TTS feedback cycle.
class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  _VoiceState _state = _VoiceState.idle;
  _VoiceState _previousStateBeforeTranscript = _VoiceState.idle;

  // Karaoke parameters
  final List<String> _karaokeWords = [
    'Синкансэн',
    '—',
    'быстрее',
    'всего',
    'добраться',
    'за',
    '¥14,000.'
  ];
  int _karaokeIndex = 0;
  Timer? _karaokeTimer;

  // Mock transcript events
  final List<KaiTranscriptEvent> _mockEvents = [
    const KaiTranscriptEvent(
      who: 'you',
      text: 'Как быстрее всего добраться до Токио из Киото?',
      timestamp: '12:30',
    ),
    const KaiTranscriptEvent(
      who: 'kai',
      text: 'Синкансэн — быстрее всего, займет около 2 часов 15 минут.',
      timestamp: '12:30',
    ),
    const KaiTranscriptEvent(
      who: 'you',
      text: 'Сколько стоит билет?',
      timestamp: '12:33',
    ),
    const KaiTranscriptEvent(
      who: 'kai',
      text: 'JR Pass на 7 дней покроет эту поездку, либо отдельный билет в одну сторону обойдется примерно в ¥14,000.',
      timestamp: '12:34',
    ),
  ];

  @override
  void dispose() {
    _stopKaraokeTimer();
    super.dispose();
  }

  void _stopKaraokeTimer() {
    _karaokeTimer?.cancel();
    _karaokeTimer = null;
  }

  void _startSpeakingSimulation() {
    _stopKaraokeTimer();
    setState(() {
      _state = _VoiceState.speaking;
      _karaokeIndex = 0;
    });

    _karaokeTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!mounted) return;
      setState(() {
        if (_karaokeIndex < _karaokeWords.length - 1) {
          _karaokeIndex++;
        } else {
          _stopKaraokeTimer();
          // After finishing the sentence, wait 1.5s then return to idle
          Timer(const Duration(milliseconds: 1500), () {
            if (mounted && _state == _VoiceState.speaking) {
              setState(() {
                _state = _VoiceState.idle;
              });
            }
          });
        }
      });
    });
  }

  void _handleTap() {
    if (_state == _VoiceState.idle) {
      setState(() {
        _state = _VoiceState.listening;
      });
    } else if (_state == _VoiceState.listening) {
      _startSpeakingSimulation();
    } else if (_state == _VoiceState.speaking) {
      // Tap during speaking interrupts it and returns to idle
      _stopKaraokeTimer();
      setState(() {
        _state = _VoiceState.idle;
      });
    }
  }

  void _goToTranscript() {
    if (_state != _VoiceState.transcript) {
      setState(() {
        _previousStateBeforeTranscript = _state;
        _state = _VoiceState.transcript;
      });
    }
  }

  void _returnFromTranscript() {
    if (_state == _VoiceState.transcript) {
      setState(() {
        _state = _previousStateBeforeTranscript;
      });
      // If returning to speaking, restart the simulation
      if (_state == _VoiceState.speaking) {
        _startSpeakingSimulation();
      }
    }
  }

  void _handleVerticalDrag(DragEndDetails details) {
    // Swipe up (negative velocity) to view transcript
    // Swipe down (positive velocity) to return
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -200) {
      _goToTranscript();
    } else if (velocity > 200) {
      _returnFromTranscript();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Deep dark background literal (#08080A) matching specs
    const voiceBg = Color(0xFF08080A);

    return Scaffold(
      backgroundColor: voiceBg,
      body: SafeArea(
        child: GestureDetector(
          onVerticalDragEnd: _handleVerticalDrag,
          onTap: _state == _VoiceState.transcript ? null : _handleTap,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              // Notch/island bar
              Align(
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
              ),

              // Return button to go back to main RoomScreen
              Positioned(
                top: 46,
                left: 18,
                child: GestureDetector(
                  onTap: () => context.go('/room'),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 14,
                      color: Color(0x66FFFFFF),
                    ),
                  ),
                ),
              ),

              // Dynamic content layer
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _state == _VoiceState.transcript
                    ? _buildTranscriptView()
                    : _buildVoiceLayout(),
              ),

              // Bottom home indicator bar
              Align(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceLayout() {
    // Determine large wave state
    final largeTideState = switch (_state) {
      _VoiceState.idle => KaiTideLargeState.idle,
      _VoiceState.listening => KaiTideLargeState.listening,
      _VoiceState.speaking => KaiTideLargeState.speaking,
      _VoiceState.transcript => KaiTideLargeState.idle,
    };

    return Stack(
      key: const ValueKey<String>('voice_layout'),
      children: [
        // Top instruction hints (only when not in transcript)
        Positioned(
          top: 46,
          left: 50,
          child: Text(
            _state == _VoiceState.idle
                ? 'нажмите, чтобы говорить'
                : (_state == _VoiceState.listening ? 'слушаю…' : 'kai говорит'),
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 9,
              color: Color(0x40FFFFFF),
              letterSpacing: 0.12,
            ),
          ),
        ),
        Positioned(
          top: 46,
          right: 18,
          child: GestureDetector(
            onTap: _goToTranscript,
            child: const Text(
              'SWIPE ↑',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 9,
                color: Color(0x40FFFFFF),
                letterSpacing: 0.12,
              ),
            ),
          ),
        ),

        // Centered large animated wave + text cluster
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Wave
                KaiTideLarge(state: largeTideState),
                const SizedBox(height: 28),
                // Text slot
                Container(
                  height: 80,
                  alignment: Alignment.center,
                  child: _state == _VoiceState.speaking
                      ? KaiKaraokeText(
                          words: _karaokeWords,
                          currentIndex: _karaokeIndex,
                        )
                      : Text(
                          _state == _VoiceState.listening
                              ? 'Говорите…'
                              : 'Kai ожидает',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _state == _VoiceState.listening
                                ? Colors.white
                                : const Color(0x52FFFFFF),
                            letterSpacing: 16 * -0.01,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTranscriptView() {
    return Column(
      key: const ValueKey<String>('transcript_view'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        const Padding(
          padding: EdgeInsets.fromLTRB(22, 50, 22, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Mini wave representing the header tide
              SizedBox(
                width: 56,
                height: 8,
                child: KaiTideCurve(
                  state: KaiTide.muted,
                  height: 8,
                ),
              ),
              // Time label
              Text(
                'сегодня · 12:34',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0x66FFFFFF),
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
        // Divider line
        Container(
          height: 1,
          color: const Color(0x0FFFFFFF),
        ),
        // Timeline content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 14, bottom: 80),
            child: KaiTranscriptView(events: _mockEvents),
          ),
        ),
        // Return button at bottom
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 26),
            child: GestureDetector(
              onTap: _returnFromTranscript,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: const Text(
                  'НАЖМИТЕ, ЧТОБЫ ВЕРНУТЬСЯ',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0x66FFFFFF),
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
