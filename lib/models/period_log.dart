import 'package:hive_ce/hive_ce.dart';

enum FlowIntensity { light, medium, heavy }

@HiveType(typeId: 0)
class PeriodLog extends HiveObject {
  @HiveField(0)
  final DateTime startDate;

  @HiveField(1)
  final int duration;

  @HiveField(2)
  final String? flowIntensity;

  @HiveField(3)
  final List<String>? symptoms;

  @HiveField(4)
  final String? mood;

  @HiveField(5)
  final DateTime? endDate;

  @HiveField(6)
  final bool isAM;

  PeriodLog({
    required this.startDate,
    required this.duration,
    this.flowIntensity,
    this.symptoms,
    this.mood,
    this.endDate,
    this.isAM = true,
  });
}

// Manual Adapter since build_runner might not be available
class PeriodLogAdapter extends TypeAdapter<PeriodLog> {
  @override
  final int typeId = 0;

  @override
  PeriodLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PeriodLog(
      startDate: fields[0] as DateTime,
      duration: fields[1] as int,
      flowIntensity: fields[2] as String?,
      symptoms: (fields[3] as List?)?.cast<String>(),
      mood: fields[4] as String?,
      endDate: fields[5] as DateTime?,
      isAM: fields[6] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, PeriodLog obj) {
    writer
      ..writeByte(7) // Updated count
      ..writeByte(0)
      ..write(obj.startDate)
      ..writeByte(1)
      ..write(obj.duration)
      ..writeByte(2)
      ..write(obj.flowIntensity)
      ..writeByte(3)
      ..write(obj.symptoms)
      ..writeByte(4)
      ..write(obj.mood)
      ..writeByte(5)
      ..write(obj.endDate)
      ..writeByte(6)
      ..write(obj.isAM);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeriodLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
