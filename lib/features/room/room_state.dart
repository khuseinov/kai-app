import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

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
  }) : tideState = tideState ?? KaiTide.idle;

  final List<Map<String, dynamic>> messages;
  final RoomFrame currentFrame;
  final KaiTideState tideState;
  final bool isStreaming;
  final String? activeSessionId;

  /// id of the Kai message currently being streamed.
  final String? streamingMessageId;

  RoomStateData copyWith({
    List<Map<String, dynamic>>? messages,
    RoomFrame? currentFrame,
    KaiTideState? tideState,
    bool? isStreaming,
    Object? activeSessionId = _sentinel,
    Object? streamingMessageId = _sentinel,
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
    );
  }
}

const _sentinel = Object();

final roomNotifierProvider =
    NotifierProvider<RoomNotifier, RoomStateData>(RoomNotifier.new);

class RoomNotifier extends Notifier<RoomStateData> {
  Completer<void>? _cancelCompleter;

  @override
  RoomStateData build() => const RoomStateData();

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
      currentFrame: RoomFrame.live,
      tideState: KaiTide.thinking,
      isStreaming: true,
      streamingMessageId: kaiMsgId,
    );

    _cancelCompleter = Completer<void>();

    final chatRepository = ref.read(chatRepositoryProvider);

    try {
      final subscription = chatRepository.sendMessage(text, sessionId).listen(
        _handleEvent,
        onDone: _onStreamDone,
        onError: (Object e) => _onStreamError(),
        cancelOnError: true,
      );
      _cancelCompleter!.future.then((_) => subscription.cancel());
    } catch (_) {
      _setErrorState();
    }
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
        if (_cancelCompleter != null && !_cancelCompleter!.isCompleted) {
          _cancelCompleter!.complete();
        }
      case ChatEventError():
        _setErrorState();
        if (_cancelCompleter != null && !_cancelCompleter!.isCompleted) {
          _cancelCompleter!.complete();
        }
      // Ignore in Phase 5a.
      case ChatEventThinking():
      case ChatEventMetadata():
      case ChatEventApproval():
    }
  }

  void _onStreamDone() {
    // If we're still streaming after stream closes, treat it as done.
    if (state.isStreaming) {
      _markKaiMessageDone(status: 'ok');
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
    state = state.copyWith(
      messages: updated,
      isStreaming: false,
      currentFrame: RoomFrame.live,
      tideState: KaiTide.idle,
      streamingMessageId: null,
    );
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

  void openNavPanel() {
    state = state.copyWith(currentFrame: RoomFrame.panel);
  }

  void closeNavPanel() {
    final hasMessages = state.messages.isNotEmpty;
    state = state.copyWith(
      currentFrame: hasMessages ? RoomFrame.live : RoomFrame.empty,
    );
  }

  void switchSession(String sessionId) {
    state = RoomStateData(
      tideState: KaiTide.idle,
      activeSessionId: sessionId,
    );
  }

  Future<void> cancelStreaming() async {
    if (_cancelCompleter != null && !_cancelCompleter!.isCompleted) {
      _cancelCompleter!.complete();
    }
  }
}
