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

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _repository;
  final OfflineQueue? _offlineQueue;
  final _uuid = const Uuid();
  String? _currentSessionId;

  ChatNotifier(this._repository, [this._offlineQueue])
      : super(const ChatState()) {
    _currentSessionId = _uuid.v4();
    _setupOfflineQueue();
  }

  String? get currentSessionId => _currentSessionId;

  void _setupOfflineQueue() {
    if (_offlineQueue != null) {
      _offlineQueue!.onFlushMessage = (msg) async {
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
      final messages = _repository.getMessagesForSession(sessionId);
      state = ChatState(messages: messages);
    }
  }

  void initSession() {
    if (_currentSessionId == null) {
      _currentSessionId = _uuid.v4();
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (_currentSessionId == null) {
      _currentSessionId = _uuid.v4();
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final kaiMsg = await _repository.sendMessage(
        text: text,
        sessionId: _currentSessionId!,
        onMessageSavedLocally: (userMsg) {
          state = state.copyWith(messages: [...state.messages, userMsg]);
        },
      );

      state = state.copyWith(
        messages: [...state.messages, kaiMsg],
        isLoading: false,
      );
    } on OfflineException {
      // Message was queued — stop loading, don't show error
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to send message: $e',
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

final chatNotifierProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(
    ref.watch(chatRepositoryProvider),
    ref.watch(offlineQueueProvider),
  );
});
