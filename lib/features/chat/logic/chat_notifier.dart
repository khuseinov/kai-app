import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/api/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/models/chat_message.dart';
import '../data/chat_repository.dart';
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
  final _uuid = const Uuid();
  String? _currentSessionId;

  ChatNotifier(this._repository) : super(const ChatState()) {
    _currentSessionId = _uuid.v4();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final kaiMsg = await _repository.sendMessage(
        text: text,
        sessionId: _currentSessionId!,
        onMessageSavedLocally: (userMsg) {
          // Immediately show user message
          state = state.copyWith(messages: [...state.messages, userMsg]);
        },
      );

      // Show KAI response
      state = state.copyWith(
        messages: [...state.messages, kaiMsg],
        isLoading: false,
      );
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
  // In a real app we would ensure boxes are opened before accessing them
  return ChatLocalSource(
    chatBox: Hive.box('settings'), // fallback for brevity
    sessionBox: Hive.box('settings'),
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
  );
});

final chatNotifierProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref.watch(chatRepositoryProvider));
});
