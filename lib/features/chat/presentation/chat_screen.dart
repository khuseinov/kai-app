import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/components/kai_gemini_wave.dart';
import '../../../../core/design/theme/theme_extensions.dart';
import '../../../core/design/tokens/kai_spacing.dart';
import '../../../core/providers/connectivity_status_provider.dart';
import '../logic/chat_notifier.dart';
import '../logic/session_notifier.dart';
import 'widgets/chat_empty_state.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/message_list.dart';
import 'widgets/offline_banner.dart';
import 'widgets/safety_block_banner.dart';
import 'widgets/session_drawer.dart';

// APP-TOOL-GATE-NOTICE-1: one-time in-session flag so the snackbar fires once.
final _toolsSeenInSessionProvider = StateProvider<bool>((ref) => false);

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  final _textController = TextEditingController();
  bool _isListening = false;

  // Full-screen drawer state
  AnimationController? _drawerController;
  Animation<double>? _drawerAnimation;
  bool _drawerOpen = false;

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _drawerAnimation = CurvedAnimation(
      parent: _drawerController!,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSession();
    });
  }

  void _openDrawer() {
    if (_drawerOpen || _drawerController == null) return;
    _drawerOpen = true;
    _drawerController!.forward();
  }

  void _closeDrawer() {
    if (!_drawerOpen || _drawerController == null) return;
    _drawerOpen = false;
    _drawerController!.reverse();
  }

  void _initSession() {
    final sessionState = ref.read(sessionNotifierProvider);
    final chatNotifier = ref.read(chatNotifierProvider.notifier);

    if (sessionState.activeSessionId != null) {
      chatNotifier.setSession(sessionState.activeSessionId!);
    } else {
      chatNotifier.initSession();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _drawerController?.dispose();
    super.dispose();
  }

  KaiVoiceState _voiceStateFromChat(ChatState state) {
    if (_isListening) {
      if (state.isLoading) return KaiVoiceState.thinking;
      return KaiVoiceState.listening;
    }
    return KaiVoiceState.idle;
  }

  void _showInputSheet() {
    if (_isListening) {
      setState(() {
        _isListening = false;
      });
    }

    final chatState = ref.read(chatNotifierProvider);
    final colors = context.kaiColors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.background,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ChatInputBar(
          controller: _textController,
          isLoading: chatState.isLoading,
          onSend: (text) {
            setState(() => _isListening = false);
            ref.read(chatNotifierProvider.notifier).sendMessage(text);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final colors = context.kaiColors;
    final isOfflineAsync = ref.watch(isOnlineProvider);

    // APP-TOOL-GATE-NOTICE-1: show one-time snackbar when tools first fire.
    ref.listen<ChatState>(chatNotifierProvider, (_, next) {
      if (ref.read(_toolsSeenInSessionProvider)) return;
      if (next.messages.any((m) => m.executedToolCalls.isNotEmpty)) {
        ref.read(_toolsSeenInSessionProvider.notifier).state = true;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.handyman_outlined, size: 14, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Kai проверяет источники данных'),
                ],
              ),
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });
    final isOffline = !(isOfflineAsync.valueOrNull ?? true);

    final voiceState = _voiceStateFromChat(chatState);

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          // Main chat content with tap-only gesture handling.
          // Horizontal drag is handled by a separate edge zone (below)
          // to avoid accidental drawer opens from swiping anywhere.
          KaiGeminiWave(
            state: voiceState,
            child: RawGestureDetector(
              behavior: HitTestBehavior.translucent,
              gestures: {
                TapGestureRecognizer:
                    GestureRecognizerFactoryWithHandlers<
                        TapGestureRecognizer>(
                  () => TapGestureRecognizer(),
                  (instance) {
                    instance.onTapUp = (_) {
                      if (_drawerOpen) {
                        _closeDrawer();
                        return;
                      }
                      HapticFeedback.lightImpact();
                      setState(() {
                        _isListening = !_isListening;
                      });
                    };
                  },
                ),
              },
              child: SafeArea(
                child: Column(
                  children: [
                    OfflineBanner(isOffline: isOffline),

                    SafetyBlockBanner(
                      latestMessage: chatState.messages.isEmpty
                          ? null
                          : chatState.messages.lastWhere(
                              (m) => !m.isUser,
                              orElse: () => chatState.messages.last,
                            ),
                    ),

                    if (chatState.error != null)
                      _ErrorBanner(
                        error: chatState.error!,
                        errorType: chatState.errorType,
                      ),

                    Expanded(
                      child: chatState.messages.isEmpty &&
                              !chatState.isLoading
                          ? ChatEmptyState(
                                voiceState: voiceState,
                                onPromptTapped: (text) {
                                  ref
                                      .read(chatNotifierProvider.notifier)
                                      .sendMessage(text);
                                },
                              )
                          : MessageList(
                                messages: chatState.messages,
                                isLoading: chatState.isLoading,
                                onRetry: (messageId) {
                                  final failedMsg =
                                      chatState.messages.firstWhere(
                                    (m) => m.id == messageId,
                                  );
                                  ref
                                      .read(chatNotifierProvider.notifier)
                                      .sendMessage(failedMsg.content);
                                },
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Left edge swipe zone — only area that triggers drawer open.
          // 20px strip along the left edge so center/right swipes are ignored.
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 20,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (_) {},
              onHorizontalDragEnd: (details) {
                // Swipe right from left edge -> open drawer
                if (!_drawerOpen &&
                    (details.primaryVelocity ?? 0) > 500) {
                  _openDrawer();
                }
              },
              child: const SizedBox.expand(),
            ),
          ),

          // Visual affordance: tappable pill handle + swipe-up to open input
          if (!_isListening)
            Positioned(
              left: 0,
              right: 0,
              bottom: 32,
              height: 56,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showInputSheet();
                },
                onVerticalDragEnd: (details) {
                  if ((details.primaryVelocity ?? 0) < -400) {
                    HapticFeedback.lightImpact();
                    _showInputSheet();
                  }
                },
                child: Center(
                  child: _AnimatedPill(colors: colors),
                ),
              ),
            ),

          // Full-screen drawer overlay
          if (_drawerAnimation != null)
            AnimatedBuilder(
              animation: _drawerAnimation!,
              builder: (context, child) {
                if (_drawerAnimation!.value == 0 && !_drawerOpen) {
                  return const SizedBox.shrink();
                }
                return Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _closeDrawer,
                    onHorizontalDragEnd: (details) {
                      if ((details.primaryVelocity ?? 0) < -300) {
                        _closeDrawer();
                      }
                    },
                    child: Container(
                      color: Colors.black.withValues(
                          alpha: 0.5 * _drawerAnimation!.value),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionalTranslation(
                          translation: Offset(
                              -1.0 + _drawerAnimation!.value, 0.0),
                          child: FractionallySizedBox(
                            widthFactor: 1.0,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 16,
                                    offset: const Offset(4, 0),
                                  ),
                                ],
                              ),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {},
                                onHorizontalDragEnd: (details) {
                                  if ((details.primaryVelocity ?? 0) <
                                      -300) {
                                    _closeDrawer();
                                  }
                                },
                                child: SessionDrawer(
                                  onClose: _closeDrawer,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// QW-4: Error banner with contextual icon + color per error type.
class _ErrorBanner extends StatelessWidget {
  final String error;
  final ChatErrorType? errorType;

  const _ErrorBanner({required this.error, this.errorType});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    final (icon, color) = switch (errorType) {
      ChatErrorType.rateLimited => (Icons.hourglass_empty, colors.warning),
      ChatErrorType.serviceUnavailable => (
          Icons.cloud_off_outlined,
          colors.error
        ),
      ChatErrorType.network => (Icons.wifi_off_rounded, colors.warning),
      _ => (Icons.error_outline, colors.error),
    };

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: KaiSpacing.screenPadding,
        vertical: KaiSpacing.xxs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: KaiSpacing.m,
        vertical: KaiSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: KaiSpacing.xs),
          Expanded(
            child: Text(
              error,
              style: typography.labelMedium.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated pill handle that gently pulses to invite interaction.
class _AnimatedPill extends StatefulWidget {
  final dynamic colors;
  const _AnimatedPill({required this.colors});

  @override
  State<_AnimatedPill> createState() => _AnimatedPillState();
}

class _AnimatedPillState extends State<_AnimatedPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _opacityAnim = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnim.value,
          child: Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: widget.colors.textTertiary,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
