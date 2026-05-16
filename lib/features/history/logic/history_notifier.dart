import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/chat_message.dart';
import '../../../core/providers/settings_provider.dart';
import '../data/history_remote_source.dart';

class HistoryState {
  final List<SessionSummary> sessions;
  final bool isLoading;
  final String? error;
  final String? selectedSessionId;
  final List<HistoryMessage> selectedMessages;
  final bool isLoadingMessages;

  const HistoryState({
    this.sessions = const [],
    this.isLoading = false,
    this.error,
    this.selectedSessionId,
    this.selectedMessages = const [],
    this.isLoadingMessages = false,
  });

  HistoryState copyWith({
    List<SessionSummary>? sessions,
    bool? isLoading,
    String? error,
    String? selectedSessionId,
    List<HistoryMessage>? selectedMessages,
    bool? isLoadingMessages,
  }) =>
      HistoryState(
        sessions: sessions ?? this.sessions,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        selectedSessionId: selectedSessionId ?? this.selectedSessionId,
        selectedMessages: selectedMessages ?? this.selectedMessages,
        isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      );
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final HistoryRemoteSource _remote;
  final String _userId;
  final _uuid = const Uuid();

  HistoryNotifier(this._remote, this._userId) : super(const HistoryState()) {
    loadSessions();
  }

  Future<void> loadSessions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final sessions = await _remote.listSessions(_userId);
      state = state.copyWith(isLoading: false, sessions: sessions);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Не удалось загрузить историю',
      );
    }
  }

  Future<void> selectSession(String sessionId) async {
    state = HistoryState(
      sessions: state.sessions,
      selectedSessionId: sessionId,
      isLoadingMessages: true,
    );
    try {
      final messages = await _remote.getMessages(sessionId);
      state = state.copyWith(
        isLoadingMessages: false,
        selectedMessages: messages,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMessages: false,
        error: 'Не удалось загрузить сообщения',
      );
    }
  }

  void clearSelection() {
    state = HistoryState(sessions: state.sessions);
  }

  /// Converts selected session messages to ChatMessage list for chat resume.
  List<ChatMessage> buildChatMessages(String sessionId) {
    return state.selectedMessages.map((m) {
      return ChatMessage(
        id: _uuid.v4(),
        content: m.content,
        isUser: m.role == 'user',
        timestamp: DateTime.tryParse(m.timestamp) ?? DateTime.now(),
        sessionId: sessionId,
        status: 'sent',
        model: m.model,
        latencyMs: m.latencyMs,
      );
    }).toList();
  }
}

final historyNotifierProvider =
    StateNotifierProvider.autoDispose<HistoryNotifier, HistoryState>((ref) {
  final userId = ref.watch(settingsProvider.select((s) => s.userId));
  return HistoryNotifier(ref.watch(historyRemoteSourceProvider), userId);
});
