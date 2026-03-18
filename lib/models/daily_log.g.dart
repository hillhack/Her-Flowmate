// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyLogAdapter extends TypeAdapter<DailyLog> {
  @override
  final int typeId = 1;

  @override
  DailyLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyLog(
      date: fields[0] as DateTime,
      isPeriodDay: fields[1] as bool,
      flowLevel: fields[2] as String,
      cramps: fields[3] as String,
      mood: fields[4] as String,
      energy: fields[5] as String,
      sleep: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DailyLog obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.isPeriodDay)
      ..writeByte(2)
      ..write(obj.flowLevel)
      ..writeByte(3)
      ..write(obj.cramps)
      ..writeByte(4)
      ..write(obj.mood)
      ..writeByte(5)
      ..write(obj.energy)
      ..writeByte(6)
      ..write(obj.sleep);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
