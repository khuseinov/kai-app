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
import 'widgets/session_drawer.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with SingleTickerProviderStateMixin {
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
    final isOffline = !(isOfflineAsync.valueOrNull ?? true);

    final voiceState = _voiceStateFromChat(chatState);

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          // Main chat content with gesture handling
          // RawGestureDetector separates tap and horizontal drag into
          // independent recognizers so they don't compete in the arena.
          // This prevents the horizontal drag from being blocked by the
          // tap recognizer's hold-during-disambiguation behavior.
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
                    instance.onTapDown = (_) {
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
                HorizontalDragGestureRecognizer:
                    GestureRecognizerFactoryWithHandlers<
                        HorizontalDragGestureRecognizer>(
                  () => HorizontalDragGestureRecognizer(),
                  (instance) {
                    instance.onEnd = (details) {
                      // Swipe right -> open drawer
                      if (!_drawerOpen &&
                          (details.primaryVelocity ?? 0) > 300) {
                        _openDrawer();
                      }
                      // Swipe left -> close drawer
                      if (_drawerOpen &&
                          (details.primaryVelocity ?? 0) < -300) {
                        _closeDrawer();
                      }
                    };
                  },
                ),
              },
              child: SafeArea(
                child: Column(
                  children: [
                    OfflineBanner(isOffline: isOffline),

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

          // Swipe-up zone at bottom edge to show text input
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 48,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragEnd: (details) {
                if ((details.primaryVelocity ?? 0) < -300) {
                  HapticFeedback.lightImpact();
                  _showInputSheet();
                }
              },
              child: const SizedBox.expand(),
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
