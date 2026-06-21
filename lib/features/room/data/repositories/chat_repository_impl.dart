import 'dart:async';

import 'package:dio/dio.dart';
import 'package:kai_app/core/network/sse_parser.dart';
import 'package:kai_app/core/storage/hive_setup.dart';
import 'package:kai_app/features/room/data/models/message.dart';
import 'package:kai_app/features/room/domain/repositories/chat_repository.dart';
import 'package:uuid/uuid.dart';

/// Factory function that opens an SSE byte-stream for a given [text] and
/// [sessionId]. Injected so tests can stub without Dio.
typedef SseStreamOpener = Stream<List<int>> Function(
  String text,
  String sessionId,
);

/// Real implementation of [ChatRepository] backed by Dio SSE streaming.
///
/// Anti-regression patterns baked in:
/// - T8  — optimistic persist of user message before stream opens
/// - T21 — correction event replaces content (not appends)
/// - T25 — session-switch guard: cancel completer checked per event
/// - T30 — terminal events (Done/Error) break the loop
/// - T31 — Completer guards (never complete an already-completed Completer)
/// - T32 — stream-started guard: only persist kai message if content or thinking
/// - T33 — per-message try/catch in _safelyPersistMessages
/// - T35 — cancel-aware drain via cancelCompleter.isCompleted check
/// - T36 — microtask yield after ChatEventState for cognitive status queue
class RealChatRepository implements ChatRepository {
  RealChatRepository({required SseStreamOpener streamOpener})
      : _streamOpener = streamOpener;

  /// Production constructor — uses Dio.
  factory RealChatRepository.withDio(Dio dio, {required String userId}) {
    return RealChatRepository(
      streamOpener: (text, sessionId) async* {
        final response = await dio.post<ResponseBody>(
          '/chat/stream',
          data: <String, dynamic>{
            'message': text,
            'user_id': userId,
            'session_id': sessionId,
          },
          options: Options(responseType: ResponseType.stream),
        );
        yield* response.data!.stream;
      },
    );
  }

  final SseStreamOpener _streamOpener;
  final Map<String, Completer<void>> _cancelCompleters = {};

  static const _uuid = Uuid();

  @override
  Stream<ChatEvent> sendMessage(String text, String sessionId) async* {
    // Synchronously claim the cancellation slot before any await, so concurrent
    // calls cannot overwrite each other's handle (race-free).
    final previousCompleter = _cancelCompleters.remove(sessionId);
    final cancelCompleter = Completer<void>();
    _cancelCompleters[sessionId] = cancelCompleter;
    if (previousCompleter != null && !previousCompleter.isCompleted) {
      previousCompleter.complete();
    }

    // T8: optimistic persist user message to Hive BEFORE starting stream
    final userMsg = Message(
      id: _uuid.v4(),
      sessionId: sessionId,
      role: MessageRole.user,
      status: MessageStatus.sent,
      content: text,
      createdAt: DateTime.now(),
    );
    await _safelyPersistMessages([userMsg]); // T33

    final kaiMsgId = _uuid.v4();
    var kaiContent = '';
    var hasContent = false;
    var cogStepCount = 0;

    try {
      final eventStream = SseParser.parse(_streamOpener(text, sessionId));
      // T35: takeWhile closes the stream at the Dart level once cancelled,
      // preventing an indefinite block on a stalled SSE connection.
      await for (final event
          in eventStream.takeWhile((_) => !cancelCompleter.isCompleted)) {
        // T36: microtask yield after state event for cognitive status queue
        if (event is ChatEventState) {
          await Future<void>.microtask(() {});
        }

        // Accumulate content for T32 persist guard
        switch (event) {
          case ChatEventMessage(:final content):
            kaiContent += content;
            hasContent = true;
          case ChatEventCorrection(:final content): // T21: replace, not append
            kaiContent = content;
            hasContent = true;
          case ChatEventThinking():
            cogStepCount++;
          default:
            break;
        }

        yield event;

        // T30: terminal events break the loop
        if (event is ChatEventDone) {
          // T32: only persist kai message if there's content or cognitive steps
          if (hasContent || cogStepCount > 0) {
            final kaiMsg = Message(
              id: kaiMsgId,
              sessionId: sessionId,
              role: MessageRole.kai,
              status: MessageStatus.sent,
              content: kaiContent,
              createdAt: DateTime.now(),
            );
            await _safelyPersistMessages([kaiMsg]); // T33
          }
          break;
        }
        if (event is ChatEventError) {
          break; // T30: error terminates stream
        }
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        yield ChatEventRateLimit(retryAfter: _parseRetryAfter(e.response));
      } else {
        yield const ChatEventError(message: 'Connection error');
      }
    } catch (_) {
      // T34: on unexpected error, surface it to consumer
      yield const ChatEventError(message: 'Connection error');
    } finally {
      // T31: guard against completing an already-completed Completer
      if (!cancelCompleter.isCompleted) cancelCompleter.complete();
      // Only remove our own completer — a concurrent sendMessage may have
      // replaced it, and we must not evict theirs.
      if (_cancelCompleters[sessionId] == cancelCompleter) {
        _cancelCompleters.remove(sessionId);
      }
    }
  }

  @override
  Future<void> cancelStreaming(String sessionId) async {
    final c = _cancelCompleters.remove(sessionId);
    // T31: guard against completing an already-completed Completer
    if (c != null && !c.isCompleted) c.complete();
  }

  /// T33: per-message try/catch — one message failing to persist doesn't
  /// break others or the overall stream.
  Future<void> _safelyPersistMessages(List<Message> messages) async {
    for (final msg in messages) {
      try {
        await HiveSetup.messages.put(msg.id, msg);
      } catch (_) {
        // Persistence failure is non-fatal — stream continues
      }
    }
  }

  Duration _parseRetryAfter(Response<dynamic>? response) {
    final header = response?.headers.value('retry-after');
    final secs = int.tryParse(header ?? '');
    return secs != null ? Duration(seconds: secs) : const Duration(seconds: 60);
  }
}
