import 'package:hive_ce/hive_ce.dart';

@HiveType(typeId: 1)
class DailyLog extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final List<String>? moods;

  @HiveField(2)
  final List<String>? symptoms;

  @HiveField(3)
  final int? waterIntake; // in glasses

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final String? flowIntensity;

  @HiveField(6)
  final List<String>? physicalActivity;

  /// Hours of sleep (e.g. 7.5). Stored from daily check-in.
  @HiveField(7)
  final double? sleepHours;

  /// Subjective energy level: 1 (exhausted) to 5 (very energetic).
  @HiveField(8)
  final int? energyLevel;

  /// Subjective stress level: 1 (very calm) to 5 (very stressed).
  @HiveField(9)
  final int? stressLevel;

  /// Basal body temperature in Celsius (useful for fertility tracking).
  @HiveField(10)
  final double? basalBodyTemperature;

  /// Number of steps walked today.
  @HiveField(11)
  final int? stepsCount;

  DailyLog({
    required this.date,
    this.moods,
    this.symptoms,
    this.waterIntake,
    this.notes,
    this.flowIntensity,
    this.physicalActivity,
    this.sleepHours,
    this.energyLevel,
    this.stressLevel,
    this.basalBodyTemperature,
    this.stepsCount,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'moods': moods,
    'symptoms': symptoms,
    'waterIntake': waterIntake,
    'notes': notes,
    'flowIntensity': flowIntensity,
    'physicalActivity': physicalActivity,
    'sleepHours': sleepHours,
    'energyLevel': energyLevel,
    'stressLevel': stressLevel,
    'basalBodyTemperature': basalBodyTemperature,
    'stepsCount': stepsCount,
  };

  factory DailyLog.fromJson(Map<String, dynamic> json) => DailyLog(
    date: DateTime.parse(json['date'] as String),
    moods: (json['moods'] as List?)?.cast<String>(),
    symptoms: (json['symptoms'] as List?)?.cast<String>(),
    waterIntake: json['waterIntake'] as int?,
    notes: json['notes'] as String?,
    flowIntensity: json['flowIntensity'] as String?,
    physicalActivity: (json['physicalActivity'] as List?)?.cast<String>(),
    sleepHours: (json['sleepHours'] as num?)?.toDouble(),
    energyLevel: json['energyLevel'] as int?,
    stressLevel: json['stressLevel'] as int?,
    basalBodyTemperature: (json['basalBodyTemperature'] as num?)?.toDouble(),
    stepsCount: json['stepsCount'] as int?,
  );
}

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
      moods: (fields[1] as List?)?.cast<String>(),
      symptoms: (fields[2] as List?)?.cast<String>(),
      waterIntake: (fields[3] as num?)?.toInt(),
      notes: fields[4] as String?,
      flowIntensity: fields[5] as String?,
      physicalActivity: (fields[6] as List?)?.cast<String>(),
      sleepHours: (fields[7] as num?)?.toDouble(),
      energyLevel: (fields[8] as num?)?.toInt(),
      stressLevel: (fields[9] as num?)?.toInt(),
      basalBodyTemperature: (fields[10] as num?)?.toDouble(),
      stepsCount: (fields[11] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, DailyLog obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.moods)
      ..writeByte(2)
      ..write(obj.symptoms)
      ..writeByte(3)
      ..write(obj.waterIntake)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.flowIntensity)
      ..writeByte(6)
      ..write(obj.physicalActivity)
      ..writeByte(7)
      ..write(obj.sleepHours)
      ..writeByte(8)
      ..write(obj.energyLevel)
      ..writeByte(9)
      ..write(obj.stressLevel)
      ..writeByte(10)
      ..write(obj.basalBodyTemperature)
      ..writeByte(11)
      ..write(obj.stepsCount);
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
