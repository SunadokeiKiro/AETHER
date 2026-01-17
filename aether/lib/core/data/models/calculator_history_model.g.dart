// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculator_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CalculatorHistoryModelAdapter extends TypeAdapter<CalculatorHistoryModel> {
  @override
  final int typeId = 5;

  @override
  CalculatorHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CalculatorHistoryModel(
      id: fields[0] as String,
      expression: fields[1] as String,
      result: fields[2] as String,
      timestamp: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CalculatorHistoryModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.expression)
      ..writeByte(2)
      ..write(obj.result)
      ..writeByte(3)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalculatorHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
