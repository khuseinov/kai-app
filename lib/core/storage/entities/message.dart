import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'message.freezed.dart';
part 'message.g.dart';

/// Lifecycle state of a single message.
///
/// - [sending] — user message being POSTed.
/// - [typing] — placeholder while Kai is composing (pre-stream).
/// - [sent] — final, persisted, no further updates expected.
/// - [error] — assistant-side failure; user can retry.
/// - [failed] — user message that couldn't be sent (network etc.). Distinct
///   from [error] so the UI can distinguish "kai failed to answer" from
///   "your message didn't go out".
/// - [streaming] — assistant response is being streamed in.
@HiveType(typeId: 2)
enum MessageStatus {
  @HiveField(0)
  sending,
  @HiveField(1)
  typing,
  @HiveField(2)
  sent,
  @HiveField(3)
  error,
  @HiveField(4)
  failed,
  @HiveField(5)
  streaming,
}

/// Author of a message.
@HiveType(typeId: 3)
enum MessageRole {
  @HiveField(0)
  user,
  @HiveField(1)
  kai,
  @HiveField(2)
  system,
}

/// A single chat message persisted in the `messages_v1` Hive box.
///
/// HiveType + HiveField annotations are documentation only — see
/// [MessageAdapter] for the hand-rolled wire layout. hive_generator's
/// analyzer pin is incompatible with freezed 2.5.x today.
@freezed
@HiveType(typeId: 1)
class Message with _$Message {
  const factory Message({
    @HiveField(0) required String id,
    @HiveField(1) required String sessionId,
    @HiveField(2) required MessageRole role,
    @HiveField(3) required MessageStatus status,
    @HiveField(4) required String content,
    @HiveField(5) required DateTime createdAt,
  }) = _Message;

  factory Message.fromJson(Map<String, Object?> json) =>
      _$MessageFromJson(json);
}

/// Hive TypeAdapter for [Message]. Field count: 6 (0-5).
class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 1;

  @override
  Message read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Message(
      id: fields[0] as String,
      sessionId: fields[1] as String,
      role: fields[2] as MessageRole,
      status: fields[3] as MessageStatus,
      content: fields[4] as String,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sessionId)
      ..writeByte(2)
      ..write(obj.role)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Hive TypeAdapter for [MessageStatus].
class MessageStatusAdapter extends TypeAdapter<MessageStatus> {
  @override
  final int typeId = 2;

  @override
  MessageStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageStatus.sending;
      case 1:
        return MessageStatus.typing;
      case 2:
        return MessageStatus.sent;
      case 3:
        return MessageStatus.error;
      case 4:
        return MessageStatus.failed;
      case 5:
        return MessageStatus.streaming;
      default:
        return MessageStatus.sending;
    }
  }

  @override
  void write(BinaryWriter writer, MessageStatus obj) {
    switch (obj) {
      case MessageStatus.sending:
        writer.writeByte(0);
        break;
      case MessageStatus.typing:
        writer.writeByte(1);
        break;
      case MessageStatus.sent:
        writer.writeByte(2);
        break;
      case MessageStatus.error:
        writer.writeByte(3);
        break;
      case MessageStatus.failed:
        writer.writeByte(4);
        break;
      case MessageStatus.streaming:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Hive TypeAdapter for [MessageRole].
class MessageRoleAdapter extends TypeAdapter<MessageRole> {
  @override
  final int typeId = 3;

  @override
  MessageRole read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageRole.user;
      case 1:
        return MessageRole.kai;
      case 2:
        return MessageRole.system;
      default:
        return MessageRole.user;
    }
  }

  @override
  void write(BinaryWriter writer, MessageRole obj) {
    switch (obj) {
      case MessageRole.user:
        writer.writeByte(0);
        break;
      case MessageRole.kai:
        writer.writeByte(1);
        break;
      case MessageRole.system:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageRoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
