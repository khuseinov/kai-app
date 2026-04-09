import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_session.freezed.dart';
part 'chat_session.g.dart';

@freezed
class ChatSession with _$ChatSession {
  const factory ChatSession({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? title,
    @Default([]) List<String> messageIds,
  }) = _ChatSession;

  factory ChatSession.fromJson(Map<String, dynamic> json) => _$ChatSessionFromJson(json);
}
