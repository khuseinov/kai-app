/// In-memory store of the latest signed session token per `session_id`
/// (SEC-2 / T-03, backend `src/api/session_token.py`).
///
/// The backend returns `X-Session-Token` on every `/chat` response and — once
/// `require_session_token` is enabled server-side — requires it back on `/chat`
/// and `/sessions/{id}/messages`. `AuthInterceptor` captures the header from
/// responses and re-attaches it on matching requests.
///
/// ponytail: process-memory only. The token is deterministic server-side and
/// re-issued on every `/chat`, so a cold start just needs one chat before a
/// history fetch in the same session. Persist to secure storage only if that
/// edge case actually bites.
class SessionTokenStore {
  final Map<String, String> _tokens = {};

  void save(String sessionId, String? token) {
    if (token != null && token.isNotEmpty) {
      _tokens[sessionId] = token;
    }
  }

  String? tokenFor(String sessionId) => _tokens[sessionId];
}

/// Shared app-wide instance (single active user per install). `AuthInterceptor`
/// falls back to this when no store is injected.
final sessionTokenStore = SessionTokenStore();
