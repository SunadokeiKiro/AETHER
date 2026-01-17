// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemoModelAdapter extends TypeAdapter<MemoModel> {
  @override
  final int typeId = 0;

  @override
  MemoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemoModel(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
      isPinned: fields[5] as bool? ?? false,
      tags: (fields[6] as List?)?.cast<String>() ?? [],
      sortOrder: fields[7] as int? ?? 0,
      folderId: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MemoModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.isPinned)
      ..writeByte(6)
      ..write(obj.tags)
      ..writeByte(7)
      ..write(obj.sortOrder)
      ..writeByte(8)
      ..write(obj.folderId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
