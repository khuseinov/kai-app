import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_client.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/storage/local_storage.dart';

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
  final ApiClient _api;
  final LocalStorage _storage;
  final _uuid = const Uuid();
  String? _currentSessionId;

  ChatNotifier(this._api, this._storage) : super(const ChatState()) {
    _currentSessionId = _uuid.v4();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      error: null,
    );

    try {
      final response = await _api.sendMessage(
        message: text,
        userId: _storage.userId,
        sessionId: _currentSessionId!,
      );

      final kaiMsg = ChatMessage(
        id: _uuid.v4(),
        content: response['response'] as String? ?? '',
        isUser: false,
        timestamp: DateTime.now(),
        language: response['language'] as String?,
        model: response['model'] as String?,
        provider: response['provider'] as String?,
        requestType: response['request_type'] as String?,
        confidence: (response['confidence'] as num?)?.toDouble(),
        latencyMs: response['latency_ms'] as int?,
        tokensUsed: response['tokens_used'] as int?,
        piiBlocked: response['pii_blocked'] as bool?,
        correlationId: response['correlation_id'] as String?,
      );

      state = state.copyWith(
        messages: [...state.messages, kaiMsg],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void newSession() {
    _currentSessionId = _uuid.v4();
    state = const ChatState();
  }
}

final chatNotifierProvider = StateNotifierProvider<ChatNotifier, ChatState>(
  (ref) => ChatNotifier(
    ref.read(apiClientProvider),
    ref.read(localStorageProvider),
  ),
);
