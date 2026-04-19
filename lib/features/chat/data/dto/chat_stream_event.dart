import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_stream_event.freezed.dart';

@freezed
class ChatStreamEvent with _$ChatStreamEvent {
  const factory ChatStreamEvent.message(String content) = _EventMessage;
  const factory ChatStreamEvent.thinking(String content) = _EventThinking;
  const factory ChatStreamEvent.done() = _EventDone;
  const factory ChatStreamEvent.error(String error) = _EventError;
}
