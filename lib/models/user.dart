import 'package:hive_ce/hive_ce.dart';

@HiveType(typeId: 10) // Unique ID for User model
class User extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int age;

  @HiveField(2)
  final String goal; // 'track_cycle', 'conceive', 'pregnant'

  @HiveField(3)
  final String? imagePath;

  @HiveField(4)
  final double? weight;

  @HiveField(5)
  final double? height;

  User({
    required this.name,
    required this.age,
    required this.goal,
    this.imagePath,
    this.weight,
    this.height,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'goal': goal,
    'imagePath': imagePath,
    'weight': weight,
    'height': height,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    name: json['name'] as String,
    age: json['age'] as int,
    goal: json['goal'] as String,
    imagePath: json['imagePath'] as String?,
    weight: (json['weight'] as num?)?.toDouble(),
    height: (json['height'] as num?)?.toDouble(),
  );

  User copyWith({
    String? name,
    int? age,
    String? goal,
    String? imagePath,
    double? weight,
    double? height,
  }) => User(
    name: name ?? this.name,
    age: age ?? this.age,
    goal: goal ?? this.goal,
    imagePath: imagePath ?? this.imagePath,
    weight: weight ?? this.weight,
    height: height ?? this.height,
  );

  bool validate() {
    if (name.trim().isEmpty) return false;
    if (age <= 0 || age > 120) return false;
    return true;
  }
}

// Manual Adapter
class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 10;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      name: fields[0] as String,
      age: fields[1] as int,
      goal: fields[2] as String,
      imagePath: fields[3] as String?,
      weight: fields[4] as double?,
      height: fields[5] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.age)
      ..writeByte(2)
      ..write(obj.goal)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.weight)
      ..writeByte(5)
      ..write(obj.height);
  }
}
