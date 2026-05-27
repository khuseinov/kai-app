import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/connectivity_listener.dart';
import '../../core/providers/root.dart';
import '../../core/repositories/chat_repository.dart';
import '../../design_system/organisms/chat_list.dart';
import '../../design_system/tokens/kai_tide.dart';

/// Immutable value class for the room's UI state.
class RoomStateData {
  const RoomStateData({
    this.messages = const [],
    this.currentFrame = RoomFrame.empty,
    KaiTideState? tideState,
    this.isStreaming = false,
    this.activeSessionId,
    this.streamingMessageId,
    this.isOffline = false,
    this.isRateLimited = false,
    this.rateLimitRetryAfter,
    this.isCrisis = false,
  }) : tideState = tideState ?? KaiTide.idle;

  final List<Map<String, dynamic>> messages;
  final RoomFrame currentFrame;
  final KaiTideState tideState;
  final bool isStreaming;
  final String? activeSessionId;

  /// id of the Kai message currently being streamed.
  final String? streamingMessageId;

  final bool isOffline;
  final bool isRateLimited;
  final Duration? rateLimitRetryAfter;
  final bool isCrisis;

  RoomStateData copyWith({
    List<Map<String, dynamic>>? messages,
    RoomFrame? currentFrame,
    KaiTideState? tideState,
    bool? isStreaming,
    Object? activeSessionId = _sentinel,
    Object? streamingMessageId = _sentinel,
    bool? isOffline,
    bool? isRateLimited,
    Object? rateLimitRetryAfter = _sentinel,
    bool? isCrisis,
  }) {
    return RoomStateData(
      messages: messages ?? this.messages,
      currentFrame: currentFrame ?? this.currentFrame,
      tideState: tideState ?? this.tideState,
      isStreaming: isStreaming ?? this.isStreaming,
      activeSessionId: activeSessionId == _sentinel
          ? this.activeSessionId
          : activeSessionId as String?,
      streamingMessageId: streamingMessageId == _sentinel
          ? this.streamingMessageId
          : streamingMessageId as String?,
      isOffline: isOffline ?? this.isOffline,
      isRateLimited: isRateLimited ?? this.isRateLimited,
      rateLimitRetryAfter: rateLimitRetryAfter == _sentinel
          ? this.rateLimitRetryAfter
          : rateLimitRetryAfter as Duration?,
      isCrisis: isCrisis ?? this.isCrisis,
    );
  }
}

const _sentinel = Object();

final roomNotifierProvider =
    NotifierProvider<RoomNotifier, RoomStateData>(RoomNotifier.new);

class RoomNotifier extends Notifier<RoomStateData> {
  Completer<void>? _cancelCompleter;
  StreamSubscription<ChatEvent>? _subscription;
  Timer? _rateLimitTimer;
  Timer? _successTimer;
  Timer? _memoryTimer;
  Timer? _inactivityTimer;

  @override
  RoomStateData build() {
    ref.onDispose(() {
      _subscription?.cancel();
      if (_cancelCompleter != null && !_cancelCompleter!.isCompleted) {
        _cancelCompleter!.complete();
      }
      _rateLimitTimer?.cancel();
      _successTimer?.cancel();
      _memoryTimer?.cancel();
      _inactivityTimer?.cancel();
    });

    ref.listen<AsyncValue<bool>>(isOnlineProvider, (_, next) {
      final online = next.valueOrNull ?? true;
      if (state.isOffline == !online) return;
      state = state.copyWith(isOffline: !online);
    });

    _resetInactivityTimer();
    return const RoomStateData();
  }

  Future<void> sendMessage(String text) async {
    if (state.isStreaming) return;

    final uid = const Uuid().v4();
    final kaiMsgId = const Uuid().v4();
    final sessionId = state.activeSessionId ?? 'default-session';

    // Add user message.
    final updatedMessages = [
      ...state.messages,
      {'id': uid, 'role': 'user', 'content': text, 'status': 'ok'},
    ];

    // Add Kai placeholder message.
    final withKai = [
      ...updatedMessages,
      <String, dynamic>{'id': kaiMsgId, 'role': 'kai', 'content': '', 'status': 'pending'},
    ];

    state = state.copyWith(
      messages: withKai,
      currentFrame: RoomFrame.streaming,
      tideState: KaiTide.thinking,
      isStreaming: true,
      streamingMessageId: kaiMsgId,
    );

    _cancelCompleter = Completer<void>();

    final chatRepository = ref.read(chatRepositoryProvider);

    try {
      _subscription = chatRepository.sendMessage(text, sessionId).listen(
        _handleEvent,
        onDone: _onStreamDone,
        onError: (Object e) => _onStreamError(),
        cancelOnError: true,
      );
    } catch (_) {
      _setErrorState();
    }

    _resetInactivityTimer();
  }

  void _handleEvent(ChatEvent event) {
    switch (event) {
      case ChatEventState(:final state):
        if (state == 'thinking') {
          this.state = this.state.copyWith(tideState: KaiTide.thinking);
        } else if (state == 'responding') {
          this.state = this.state.copyWith(tideState: KaiTide.responding);
        }
      case ChatEventMessage(:final content, :final messageId):
        final current = state;
        final targetId =
            messageId.isNotEmpty ? messageId : current.streamingMessageId;
        final updated = current.messages.map((msg) {
          if (msg['id'] == targetId || msg['id'] == current.streamingMessageId) {
            final prev = msg['content'] as String? ?? '';
            return <String, dynamic>{...msg, 'content': prev + content};
          }
          return msg;
        }).toList();
        state = current.copyWith(
          messages: updated,
          currentFrame: RoomFrame.streaming,
        );
      case ChatEventCorrection(:final content, :final messageId):
        final current = state;
        final targetId =
            messageId.isNotEmpty ? messageId : current.streamingMessageId;
        final updated = current.messages.map((msg) {
          if (msg['id'] == targetId || msg['id'] == current.streamingMessageId) {
            return <String, dynamic>{...msg, 'content': content};
          }
          return msg;
        }).toList();
        state = current.copyWith(messages: updated);
      case ChatEventDone():
        _markKaiMessageDone(status: 'ok');
        _subscription?.cancel();
        _subscription = null;
        if (_cancelCompleter != null && !_cancelCompleter!.isCompleted) {
          _cancelCompleter!.complete();
        }
      case ChatEventError():
        _setErrorState();
        _subscription?.cancel();
        _subscription = null;
        if (_cancelCompleter != null && !_cancelCompleter!.isCompleted) {
          _cancelCompleter!.complete();
        }
      case ChatEventRateLimit(:final retryAfter):
        _markKaiMessageDone(status: 'ok');
        _subscription?.cancel();
        _subscription = null;
        if (_cancelCompleter != null && !_cancelCompleter!.isCompleted) {
          _cancelCompleter!.complete();
        }
        state = state.copyWith(
          isRateLimited: true,
          rateLimitRetryAfter: retryAfter,
        );
        _startRateLimitCountdown(retryAfter);
      case ChatEventMetadata(:final data):
        if (data['crisis'] == true) {
          state = state.copyWith(isCrisis: true);
        }
        if (data['memory_saved'] == true) {
          _triggerMemoryEphemeral();
        }
      // Ignore in Phase 5a.
      case ChatEventThinking():
      case ChatEventApproval():
    }
  }

  void _onStreamDone() {
    // If we're still streaming after stream closes, treat it as done.
    if (state.isStreaming) {
      _markKaiMessageDone(status: 'ok');
      _subscription = null;
      if (_cancelCompleter != null && !_cancelCompleter!.isCompleted) {
        _cancelCompleter!.complete();
      }
    }
  }

  void _onStreamError() {
    _setErrorState();
  }

  void _markKaiMessageDone({required String status}) {
    final streamingId = state.streamingMessageId;
    final updated = state.messages.map((msg) {
      if (msg['id'] == streamingId) {
        return <String, dynamic>{...msg, 'status': status};
      }
      return msg;
    }).toList();
    final nextFrame = updated.isEmpty ? RoomFrame.empty : RoomFrame.live;
    state = state.copyWith(
      messages: updated,
      isStreaming: false,
      currentFrame: nextFrame,
      tideState: KaiTide.success,
      streamingMessageId: null,
    );
    _successTimer?.cancel();
    _successTimer = Timer(const Duration(milliseconds: 1200), () {
      if (state.tideState == KaiTide.success) {
        state = state.copyWith(tideState: KaiTide.idle);
      }
    });
  }

  void _setErrorState() {
    final streamingId = state.streamingMessageId;
    final updated = state.messages.map((msg) {
      if (msg['id'] == streamingId) {
        return <String, dynamic>{...msg, 'status': 'error'};
      }
      return msg;
    }).toList();
    state = state.copyWith(
      messages: updated,
      isStreaming: false,
      currentFrame: RoomFrame.error,
      tideState: KaiTide.error,
      streamingMessageId: null,
    );
  }

  void _startRateLimitCountdown(Duration initial) {
    _rateLimitTimer?.cancel();
    var remaining = initial.inSeconds;
    _rateLimitTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      remaining--;
      if (remaining <= 0) {
        t.cancel();
        state = state.copyWith(
          isRateLimited: false,
          rateLimitRetryAfter: null,
        );
      } else {
        state = state.copyWith(rateLimitRetryAfter: Duration(seconds: remaining));
      }
    });
  }

  void _triggerMemoryEphemeral() {
    final previousTide = state.tideState;
    _memoryTimer?.cancel();
    state = state.copyWith(tideState: KaiTide.memory);
    _memoryTimer = Timer(const Duration(milliseconds: 900), () {
      if (state.tideState == KaiTide.memory) {
        state = state.copyWith(tideState: previousTide);
      }
    });
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: 60), () {
      if (!state.isStreaming) {
        state = state.copyWith(tideState: KaiTide.sleep);
      }
    });
  }

  void openNavPanel() {
    state = state.copyWith(currentFrame: RoomFrame.panel);
    _resetInactivityTimer();
  }

  void closeNavPanel() {
    final hasMessages = state.messages.isNotEmpty;
    state = state.copyWith(
      currentFrame: hasMessages ? RoomFrame.live : RoomFrame.empty,
    );
    _resetInactivityTimer();
  }

  void switchSession(String sessionId) {
    state = RoomStateData(
      tideState: KaiTide.idle,
      activeSessionId: sessionId,
    );
    _resetInactivityTimer();
  }

  Future<void> cancelStreaming() async {
    await _subscription?.cancel();
    _subscription = null;
    if (_cancelCompleter != null && !_cancelCompleter!.isCompleted) {
      _cancelCompleter!.complete();
    }
    state = state.copyWith(isStreaming: false, tideState: KaiTide.idle);
  }
}
