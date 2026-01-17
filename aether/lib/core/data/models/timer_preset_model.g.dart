// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_preset_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimerPresetModelAdapter extends TypeAdapter<TimerPresetModel> {
  @override
  final int typeId = 3;

  @override
  TimerPresetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimerPresetModel(
      id: fields[0] as String,
      label: fields[1] as String,
      durationSeconds: fields[2] as int,
      isBuiltIn: fields[3] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, TimerPresetModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.durationSeconds)
      ..writeByte(3)
      ..write(obj.isBuiltIn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimerPresetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
