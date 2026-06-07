import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'memory_fact.freezed.dart';
part 'memory_fact.g.dart';

/// A single memory fact saved about the user.
///
/// HiveType + HiveField annotations are documentation only — see
/// [MemoryFactAdapter] for the hand-rolled wire layout.
@freezed
@HiveType(typeId: 6)
class MemoryFact with _$MemoryFact {
  const factory MemoryFact({
    @HiveField(0) required String id,
    @HiveField(1) required String category, // 'about', 'preferences', 'restrictions', 'trips'
    @HiveField(2) required String text,
    @HiveField(3) required String sourceText,
    @HiveField(4) required DateTime createdAt,
    @HiveField(5) String? expiresIn,
    @HiveField(6) @Default(false) bool isCritical,
    @HiveField(7) String? sourceTripId,
  }) = _MemoryFact;

  factory MemoryFact.fromJson(Map<String, Object?> json) =>
      _$MemoryFactFromJson(json);
}

/// Hive TypeAdapter for [MemoryFact]. Maintained by hand — keep in sync with the
/// `@HiveField` annotations above. Field count: 8 (0-7).
class MemoryFactAdapter extends TypeAdapter<MemoryFact> {
  @override
  final int typeId = 6;

  @override
  MemoryFact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemoryFact(
      id: fields[0] as String? ?? '',
      category: fields[1] as String? ?? '',
      text: fields[2] as String? ?? '',
      sourceText: fields[3] as String? ?? '',
      createdAt: fields[4] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0),
      expiresIn: fields[5] as String?,
      isCritical: fields[6] as bool? ?? false,
      sourceTripId: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MemoryFact obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.sourceText)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.expiresIn)
      ..writeByte(6)
      ..write(obj.isCritical)
      ..writeByte(7)
      ..write(obj.sourceTripId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryFactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
