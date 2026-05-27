import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'session.freezed.dart';
part 'session.g.dart';

/// A single conversation between the user and Kai.
///
/// Persisted in the `chat_sessions_v1` Hive box. Versioned at the box name
/// so future schema bumps can run a migration without touching this type.
///
/// HiveType + HiveField annotations are kept here as documentation of the
/// wire layout. The TypeAdapter is hand-rolled below — hive_generator's
/// analyzer constraint clashes with freezed 2.5.x, so we can't lean on
/// generated adapters today.
@freezed
@HiveType(typeId: 0)
class Session with _$Session {
  const factory Session({
    @HiveField(0) required String id,
    @HiveField(1) required String title,
    @HiveField(2) required DateTime createdAt,
    @HiveField(3) String? tripId,
  }) = _Session;

  factory Session.fromJson(Map<String, Object?> json) =>
      _$SessionFromJson(json);
}

/// Hive TypeAdapter for [Session]. Maintained by hand — keep in sync with the
/// `@HiveField` annotations above. Field count: 4 (0-3).
class SessionAdapter extends TypeAdapter<Session> {
  @override
  final int typeId = 0;

  @override
  Session read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Session(
      id: fields[0] as String,
      title: fields[1] as String,
      createdAt: fields[2] as DateTime,
      tripId: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Session obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.tripId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
