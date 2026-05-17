import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/components/kai_gemini_wave.dart';
import '../../../../core/design/theme/theme_extensions.dart';
import '../../../core/design/tokens/kai_spacing.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/storage/local_storage.dart';
import '../logic/chat_notifier.dart';
import '../logic/session_notifier.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/memory_toast.dart';
import 'widgets/message_list.dart';
import 'widgets/safety_block_banner.dart';
import 'widgets/session_drawer.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  final _textController = TextEditingController();
  bool _isListening = false;
  bool _showHint = false;

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
      _maybeShowHint();
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

  void _maybeShowHint() {
    final storage = ref.read(localStorageProvider);
    if (!storage.kaiHintShown) {
      setState(() => _showHint = true);
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _showHint = false);
        storage.kaiHintShown = true;
      });
    }
  }

  void _showQuickActions() {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;
    final settings = ref.read(settingsProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: KaiSpacing.s),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: KaiSpacing.m),
                decoration: BoxDecoration(
                  color: colors.cloudLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.add_comment_outlined,
                    color: colors.oceanPrimary),
                title: Text('Новый разговор',
                    style: typography.bodyLarge
                        .copyWith(color: colors.textPrimary)),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(chatNotifierProvider.notifier).initSession();
                },
              ),
              ListTile(
                leading: Icon(Icons.palette_outlined,
                    color: colors.textSecondary),
                title: Text('Тема', style: typography.bodyLarge.copyWith(color: colors.textPrimary)),
                trailing: DropdownButton<ThemeMode>(
                  value: settings.themeMode,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: ThemeMode.system, child: Text('Авто')),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Светлая')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Тёмная')),
                  ],
                  onChanged: (mode) {
                    if (mode != null) {
                      ref.read(settingsProvider.notifier).setThemeMode(mode);
                    }
                  },
                ),
              ),
              ListTile(
                leading:
                    Icon(Icons.delete_sweep_outlined, color: colors.error),
                title: Text('Очистить сессию',
                    style: typography.bodyLarge.copyWith(color: colors.error)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (d) => AlertDialog(
                      title: const Text('Очистить?'),
                      content: const Text(
                          'История этой сессии будет удалена.'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(d, false),
                            child: const Text('Отмена')),
                        TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: colors.error),
                            onPressed: () => Navigator.pop(d, true),
                            child: const Text('Очистить')),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    ref.read(chatNotifierProvider.notifier).initSession();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
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
    if (state.isLoading) return KaiVoiceState.thinking;
    if (_isListening) return KaiVoiceState.listening;
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
    final typography = context.kaiTypography;
    final reduceMotion =
        ref.watch(settingsProvider.select((s) => s.reduceMotion));

    // Kai-invoked: surface MemoryToast when backend marks a message as
    // memorize (specialMode == 'M'). The widget itself dedupes via shown-ids.
    ref.listen<ChatState>(chatNotifierProvider, (_, __) {
      if (mounted) MemoryToast.maybeShow(context, ref);
    });

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
            reduceMotion: reduceMotion,
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
                      child: MessageList(
                        messages: chatState.messages,
                        isLoading: chatState.isLoading,
                        onRetry: (messageId) {
                          final failedMsg = chatState.messages.firstWhere(
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
                  child: Container(
                    width: 24,
                    height: 3,
                    decoration: BoxDecoration(
                      color: colors.textTertiary.withAlpha(77),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),

          // Stop generating button — visible only while Kai is responding
          if (chatState.isLoading)
            Positioned(
              left: 0,
              right: 0,
              bottom: 80,
              child: Center(
                child: GestureDetector(
                  onTap: () =>
                      ref.read(chatNotifierProvider.notifier).stopStream(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.cloudLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stop_rounded,
                            size: 14, color: colors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          'Стоп',
                          style: typography.labelSmall
                              .copyWith(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Top edge zone — swipe DOWN triggers QuickActionsSheet
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 40,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragEnd: (details) {
                if ((details.primaryVelocity ?? 0) > 400) {
                  HapticFeedback.lightImpact();
                  _showQuickActions();
                }
              },
              child: const SizedBox.expand(),
            ),
          ),

          // One-time hint for new users: fades out after 4s
          if (_showHint && chatState.messages.isEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _showHint ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 600),
                  child: Center(
                    child: Text(
                      'Скажите или коснитесь Kai',
                      style: typography.bodyMedium.copyWith(
                        color: colors.textTertiary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
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
