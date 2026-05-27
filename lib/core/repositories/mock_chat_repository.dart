import 'dart:async';

import 'chat_repository.dart';

/// In-memory mock that simulates realistic SSE streaming with delays.
///
/// - Multi-chunk message: 3 content chunks with 100-200ms inter-chunk delays
/// - Correction event: replaces content after all chunks
/// - Done event: terminates stream cleanly
/// - Error path: sessionId ending with ':error' triggers ChatEventError
/// - Cancel: cancelStreaming() closes stream immediately
class MockChatRepository implements ChatRepository {
  final Map<String, StreamController<ChatEvent>> _controllers = {};

  @override
  Stream<ChatEvent> sendMessage(String text, String sessionId) {
    // Close any in-flight stream for the same session before starting a new one.
    final existing = _controllers.remove(sessionId);
    if (existing != null && !existing.isClosed) existing.close();

    final controller = StreamController<ChatEvent>();
    _controllers[sessionId] = controller;
    _runFakeStream(sessionId, text, controller);
    return controller.stream;
  }

  Future<void> _runFakeStream(
    String sessionId,
    String text,
    StreamController<ChatEvent> controller,
  ) async {
    const messageId = 'msg-mock-1';
    try {
      await Future<void>.delayed(const Duration(milliseconds: 80));
      if (controller.isClosed) return;

      if (sessionId.endsWith(':error')) {
        controller.add(const ChatEventError(message: 'Mock error path'));
        await controller.close();
        _controllers.remove(sessionId);
        return;
      }

      controller.add(const ChatEventState(state: 'thinking'));
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (controller.isClosed) return;

      controller.add(const ChatEventThinking(step: 'Planning response'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (controller.isClosed) return;

      controller.add(const ChatEventState(state: 'responding'));

      const chunks = ['Hello', ' from', ' Kai!'];
      for (final chunk in chunks) {
        await Future<void>.delayed(const Duration(milliseconds: 150));
        if (controller.isClosed) return;
        controller.add(ChatEventMessage(content: chunk, messageId: messageId));
      }

      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (controller.isClosed) return;
      controller.add(
        const ChatEventCorrection(
          content: 'Hello from Kai! (corrected)',
          messageId: messageId,
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 80));
      if (controller.isClosed) return;
      controller.add(const ChatEventDone());
      await controller.close();
    } catch (_) {
      if (!controller.isClosed) await controller.close();
    } finally {
      _controllers.remove(sessionId);
    }
  }

  @override
  Future<void> cancelStreaming(String sessionId) async {
    final c = _controllers.remove(sessionId);
    if (c != null && !c.isClosed) {
      await c.close();
    }
  }
}
