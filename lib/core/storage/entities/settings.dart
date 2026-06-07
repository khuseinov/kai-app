import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'settings.freezed.dart';
part 'settings.g.dart';

/// Resolved theme preference. `system` defers to platform brightness.
@HiveType(typeId: 4)
enum AppThemeMode {
  @HiveField(0)
  system,
  @HiveField(1)
  light,
  @HiveField(2)
  dark,
}

/// Persisted app settings — single record stored under a fixed key in the
/// `settings_v1` Hive box.
///
/// HiveType + HiveField annotations are documentation only — see
/// [AppSettingsAdapter] for the hand-rolled wire layout.
@freezed
@HiveType(typeId: 5)
class AppSettings with _$AppSettings {
  const factory AppSettings({
    @HiveField(0) @Default(AppThemeMode.system) AppThemeMode themeMode,
    @HiveField(1) @Default('ru') String locale,
    @HiveField(2) @Default(false) bool onboarded,
    @HiveField(3) @Default(true) bool memoryEnabled,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, Object?> json) =>
      _$AppSettingsFromJson(json);
}

/// Hive TypeAdapter for [AppThemeMode].
class AppThemeModeAdapter extends TypeAdapter<AppThemeMode> {
  @override
  final int typeId = 4;

  @override
  AppThemeMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AppThemeMode.system;
      case 1:
        return AppThemeMode.light;
      case 2:
        return AppThemeMode.dark;
      default:
        return AppThemeMode.system;
    }
  }

  @override
  void write(BinaryWriter writer, AppThemeMode obj) {
    switch (obj) {
      case AppThemeMode.system:
        writer.writeByte(0);
        break;
      case AppThemeMode.light:
        writer.writeByte(1);
        break;
      case AppThemeMode.dark:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppThemeModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Hive TypeAdapter for [AppSettings]. Field count: 4 (0-3).
class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 5;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      themeMode: fields[0] as AppThemeMode? ?? AppThemeMode.system,
      locale: fields[1] as String? ?? 'ru',
      onboarded: fields[2] as bool? ?? false,
      memoryEnabled: fields[3] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.themeMode)
      ..writeByte(1)
      ..write(obj.locale)
      ..writeByte(2)
      ..write(obj.onboarded)
      ..writeByte(3)
      ..write(obj.memoryEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
