// HAND-WRITTEN sealed class — no codegen, no freezed

sealed class ChatEvent {
  const ChatEvent();
}

/// A chunk of message content arriving during streaming.
final class ChatEventMessage extends ChatEvent {
  const ChatEventMessage({required this.content, required this.messageId});
  final String content;
  final String messageId;
}

/// A cognitive/thinking step Kai is performing.
final class ChatEventThinking extends ChatEvent {
  const ChatEventThinking({required this.step});
  final String step;
}

/// Tide/UI state change (e.g. 'thinking', 'responding').
final class ChatEventState extends ChatEvent {
  const ChatEventState({required this.state});
  final String state;
}

/// Metadata attached to a message (e.g. memory_saved, crisis flag).
final class ChatEventMetadata extends ChatEvent {
  const ChatEventMetadata({required this.data});
  final Map<String, dynamic> data;
}

/// Kai is requesting user approval before proceeding.
final class ChatEventApproval extends ChatEvent {
  const ChatEventApproval({required this.prompt, required this.requestId});
  final String prompt;
  final String requestId;
}

/// A correction — replaces the current message content (not appends).
final class ChatEventCorrection extends ChatEvent {
  const ChatEventCorrection({required this.content, required this.messageId});
  final String content;
  final String messageId;
}

/// Stream is complete — no more events.
final class ChatEventDone extends ChatEvent {
  const ChatEventDone();
}

/// Stream terminated with an error.
final class ChatEventError extends ChatEvent {
  const ChatEventError({required this.message});
  final String message;
}

/// Rate limit reached (HTTP 429). [retryAfter] is the server-specified wait.
final class ChatEventRateLimit extends ChatEvent {
  const ChatEventRateLimit({this.retryAfter = const Duration(seconds: 60)});
  final Duration retryAfter;
}

abstract class ChatRepository {
  /// Sends [text] in session [sessionId] and returns the event stream.
  Stream<ChatEvent> sendMessage(String text, String sessionId);

  /// Cancels any in-progress stream for [sessionId].
  Future<void> cancelStreaming(String sessionId);
}
