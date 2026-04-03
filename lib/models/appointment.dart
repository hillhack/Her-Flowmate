import 'package:hive_ce/hive_ce.dart';

/// Categories for wellness reminders — no medical content.
enum WellnessCategory {
  selfCare,
  movement,
  mindfulness,
  nutrition,
  social,
  goal,
  other,
}

extension WellnessCategoryLabel on WellnessCategory {
  String get label {
    switch (this) {
      case WellnessCategory.selfCare:
        return 'Self-Care';
      case WellnessCategory.movement:
        return 'Movement';
      case WellnessCategory.mindfulness:
        return 'Mindfulness';
      case WellnessCategory.nutrition:
        return 'Nutrition';
      case WellnessCategory.social:
        return 'Social';
      case WellnessCategory.goal:
        return 'Goal';
      case WellnessCategory.other:
        return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case WellnessCategory.selfCare:
        return '🛁';
      case WellnessCategory.movement:
        return '🧘';
      case WellnessCategory.mindfulness:
        return '🧠';
      case WellnessCategory.nutrition:
        return '🥗';
      case WellnessCategory.social:
        return '💬';
      case WellnessCategory.goal:
        return '🎯';
      case WellnessCategory.other:
        return '✨';
    }
  }
}

@HiveType(typeId: 3)
class Appointment extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String? location;

  @HiveField(3)
  final String? notes;

  @HiveField(4)
  final int typeIndex; // Stores WellnessCategory.index

  Appointment({
    required this.title,
    required this.date,
    this.location,
    this.notes,
    required this.typeIndex,
  });

  WellnessCategory get category => WellnessCategory.values[typeIndex];

  Map<String, dynamic> toJson() => {
    'title': title,
    'date': date.toIso8601String(),
    'location': location,
    'notes': notes,
    'typeIndex': typeIndex,
  };

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    title: json['title'] as String,
    date: DateTime.parse(json['date'] as String),
    location: json['location'] as String?,
    notes: json['notes'] as String?,
    typeIndex: json['typeIndex'] as int,
  );
}

class AppointmentAdapter extends TypeAdapter<Appointment> {
  @override
  final int typeId = 3;

  @override
  Appointment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Appointment(
      title: fields[0] as String,
      date: fields[1] as DateTime,
      location: fields[2] as String?,
      notes: fields[3] as String?,
      typeIndex: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Appointment obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.typeIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
