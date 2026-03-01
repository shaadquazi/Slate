// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final int typeId = 1;

  @override
  Todo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Todo(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      status: fields[3] as Status,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
      repeat: fields[6] as RepeatFrequency,
      repeatEndDate: fields[7] as DateTime?,
      completedOn: fields[8] as DateTime?,
      dueDate: fields[10] as DateTime?,
      imagePath: fields[11] as String?,
    )..imageBytes = fields[9] as Uint8List?;
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.repeat)
      ..writeByte(7)
      ..write(obj.repeatEndDate)
      ..writeByte(8)
      ..write(obj.completedOn)
      ..writeByte(9)
      ..write(obj.imageBytes)
      ..writeByte(10)
      ..write(obj.dueDate)
      ..writeByte(11)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StatusAdapter extends TypeAdapter<Status> {
  @override
  final int typeId = 0;

  @override
  Status read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Status.pending;
      case 1:
        return Status.inProgress;
      case 2:
        return Status.completed;
      default:
        return Status.pending;
    }
  }

  @override
  void write(BinaryWriter writer, Status obj) {
    switch (obj) {
      case Status.pending:
        writer.writeByte(0);
        break;
      case Status.inProgress:
        writer.writeByte(1);
        break;
      case Status.completed:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RepeatFrequencyAdapter extends TypeAdapter<RepeatFrequency> {
  @override
  final int typeId = 2;

  @override
  RepeatFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RepeatFrequency.none;
      case 1:
        return RepeatFrequency.daily;
      case 2:
        return RepeatFrequency.weekly;
      case 3:
        return RepeatFrequency.monthly;
      case 4:
        return RepeatFrequency.yearly;
      default:
        return RepeatFrequency.none;
    }
  }

  @override
  void write(BinaryWriter writer, RepeatFrequency obj) {
    switch (obj) {
      case RepeatFrequency.none:
        writer.writeByte(0);
        break;
      case RepeatFrequency.daily:
        writer.writeByte(1);
        break;
      case RepeatFrequency.weekly:
        writer.writeByte(2);
        break;
      case RepeatFrequency.monthly:
        writer.writeByte(3);
        break;
      case RepeatFrequency.yearly:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepeatFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
