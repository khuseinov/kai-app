import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/chat_local_source.dart';
import '../domain/chat_session.dart';
import 'chat_notifier.dart';

class SessionState {
  final List<ChatSession> sessions;
  final String? activeSessionId;
  final bool isLoading;
  final String? error;

  const SessionState({
    this.sessions = const [],
    this.activeSessionId,
    this.isLoading = false,
    this.error,
  });

  SessionState copyWith({
    List<ChatSession>? sessions,
    String? activeSessionId,
    bool? isLoading,
    String? error,
  }) =>
      SessionState(
        sessions: sessions ?? this.sessions,
        activeSessionId: activeSessionId ?? this.activeSessionId,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class SessionNotifier extends StateNotifier<SessionState> {
  final ChatLocalSource _localSource;
  final _uuid = const Uuid();

  SessionNotifier(this._localSource) : super(const SessionState()) {
    loadSessions();
  }

  Future<void> loadSessions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final sessions = _localSource.getAllSessions();
      final activeId = state.activeSessionId ?? sessions.firstOrNull?.id;
      state = state.copyWith(
        sessions: sessions,
        activeSessionId: activeId,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load sessions: $e');
    }
  }

  String createSession() {
    final now = DateTime.now();
    final session = ChatSession(
      id: _uuid.v4(),
      createdAt: now,
      updatedAt: now,
    );
    _localSource.saveSession(session);
    final updated = [session, ...state.sessions];
    state = state.copyWith(sessions: updated, activeSessionId: session.id);
    return session.id;
  }

  void switchSession(String sessionId) {
    state = state.copyWith(activeSessionId: sessionId);
  }

  Future<void> deleteSession(String sessionId) async {
    await _localSource.deleteSession(sessionId);
    final updated = state.sessions.where((s) => s.id != sessionId).toList();
    final newActive = state.activeSessionId == sessionId
        ? updated.firstOrNull?.id
        : state.activeSessionId;
    state = state.copyWith(sessions: updated, activeSessionId: newActive);
  }

  Future<void> updateTitle(String sessionId, String title) async {
    await _localSource.updateSessionTitle(sessionId, title);
    final updated = state.sessions.map((s) {
      if (s.id == sessionId) {
        return s.copyWith(title: title, updatedAt: DateTime.now());
      }
      return s;
    }).toList();
    state = state.copyWith(sessions: updated);
  }
}

final sessionNotifierProvider =
    StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier(ref.watch(chatLocalSourceProvider));
});
