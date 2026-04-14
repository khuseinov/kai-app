import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/api/circuit_breaker.dart';
import '../../../core/network/offline_queue.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/models/chat_message.dart';
import '../data/chat_local_source.dart';
import '../data/chat_remote_source.dart';
import '../data/chat_repository.dart';
import 'session_notifier.dart';

enum ChatErrorType { rateLimited, serviceUnavailable, network, unknown }

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final ChatErrorType? errorType;
  final int? rateLimitRetryAfter;
  final String? targetMessageId;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.errorType,
    this.rateLimitRetryAfter,
    this.targetMessageId,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    ChatErrorType? errorType,
    int? rateLimitRetryAfter,
    String? targetMessageId,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        errorType: errorType,
        rateLimitRetryAfter: rateLimitRetryAfter,
        targetMessageId: targetMessageId ?? this.targetMessageId,
      );
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _repository;
  final LocalStorage _localStorage;
  final OfflineQueue? _offlineQueue;
  final SessionNotifier? _sessionNotifier;
  final _uuid = const Uuid();
  String? _currentSessionId;
  // Track if this session already has a title (first message sets it)
  bool _sessionTitled = false;

  ChatNotifier(this._repository, this._localStorage, [this._offlineQueue, this._sessionNotifier])
      : super(const ChatState()) {
    _currentSessionId = _uuid.v4();
    _setupOfflineQueue();
  }

  String? get currentSessionId => _currentSessionId;

  void _setupOfflineQueue() {
    if (_offlineQueue != null) {
      _offlineQueue.onFlushMessage = (msg) async {
        try {
          final kaiMsg = await _repository.sendMessage(
            text: msg.text,
            sessionId: msg.sessionId,
          );
          state = state.copyWith(messages: [...state.messages, kaiMsg]);
          return true;
        } catch (_) {
          return false;
        }
      };
    }
  }

  void setSession(String sessionId) {
    if (_currentSessionId != sessionId) {
      _currentSessionId = sessionId;
      _sessionTitled = false; // reset вЂ” new session may not have a title yet
      final messages = _repository.getMessagesForSession(sessionId);
      // If session already has messages, it already has a title
      if (messages.isNotEmpty) _sessionTitled = true;
      state = ChatState(messages: messages);
    }
  }

  void setTargetMessage(String id) {
    state = state.copyWith(targetMessageId: id);
  }

  void initSession() {
    _currentSessionId ??= _uuid.v4();
  }

  void _updateMessageStatus(String messageId, String status) {
    final updated = state.messages
        .map((m) => m.id == messageId ? m.copyWith(status: status) : m)
        .toList();
    state = state.copyWith(messages: updated);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _currentSessionId ??= _uuid.v4();
    state = state.copyWith(isLoading: true, error: null);

    String? userMsgId;

    try {
      final kaiMsg = await _repository.sendMessage(
        text: text,
        sessionId: _currentSessionId!,
        onMessageSavedLocally: (userMsg) {
          userMsgId = userMsg.id;
          state = state.copyWith(messages: [...state.messages, userMsg]);
          // Auto-name session on first message
          if (!_sessionTitled && _currentSessionId != null) {
            _sessionTitled = true;
            final title = text.length > 40 ? '${text.substring(0, 40)}…' : text;
            _sessionNotifier?.updateTitle(_currentSessionId!, title);
          }
        },
      );

      if (userMsgId != null) _updateMessageStatus(userMsgId!, 'sent');
      state = state.copyWith(
        messages: [...state.messages, kaiMsg],
        isLoading: false,
      );
    } on OfflineException {
      if (userMsgId != null) _updateMessageStatus(userMsgId!, 'queued');
      state = state.copyWith(isLoading: false);
    } on RateLimitException catch (e) {
      if (userMsgId != null) _updateMessageStatus(userMsgId!, 'failed');
      state = state.copyWith(
        isLoading: false,
        error: e.retryAfterSeconds != null
            ? 'Too many messages — try again in ${e.retryAfterSeconds}s'
            : 'Too many messages — please slow down',
        errorType: ChatErrorType.rateLimited,
        rateLimitRetryAfter: e.retryAfterSeconds,
      );
    } on ServiceUnavailableException catch (e) {
      if (userMsgId != null) _updateMessageStatus(userMsgId!, 'failed');
      state = state.copyWith(
        isLoading: false,
        error: e.message,
        errorType: ChatErrorType.serviceUnavailable,
      );
    } on NetworkException catch (e) {
      if (userMsgId != null) _updateMessageStatus(userMsgId!, 'failed');
      state = state.copyWith(
        isLoading: false,
        error: e.message,
        errorType: ChatErrorType.network,
      );
    } catch (e) {
      if (userMsgId != null) _updateMessageStatus(userMsgId!, 'failed');
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong. Please try again.',
        errorType: ChatErrorType.unknown,
      );
    }
  }

  void newSession() {
    _currentSessionId = _uuid.v4();
    state = const ChatState();
  }
}

final chatLocalSourceProvider = Provider<ChatLocalSource>((ref) {
  return ChatLocalSource(
    chatBox: Hive.box('chat_history'),
    sessionBox: Hive.box('sessions'),
  );
});

final chatRemoteSourceProvider = Provider<ChatRemoteSource>((ref) {
  return ChatRemoteSource(ref.watch(apiClientProvider));
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(
    ref.watch(chatRemoteSourceProvider),
    ref.watch(chatLocalSourceProvider),
    ref.watch(localStorageProvider),
    ref.watch(circuitBreakerProvider),
    ref.watch(offlineQueueProvider),
  );
});

final chatNotifierProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(
    ref.watch(chatRepositoryProvider),
    ref.watch(localStorageProvider),
    ref.watch(offlineQueueProvider),
    ref.read(sessionNotifierProvider.notifier),
  );
});
