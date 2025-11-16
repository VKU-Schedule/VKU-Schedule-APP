import 'package:hive/hive.dart';

part 'saved_schedule.g.dart';

@HiveType(typeId: 1)
class SavedSchedule extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String scheduleJson;

  @HiveField(2)
  DateTime savedAt;

  @HiveField(3)
  bool isActive;

  SavedSchedule({
    required this.id,
    required this.scheduleJson,
    required this.savedAt,
    this.isActive = false,
  });

  SavedSchedule copyWith({
    String? id,
    String? scheduleJson,
    DateTime? savedAt,
    bool? isActive,
  }) {
    return SavedSchedule(
      id: id ?? this.id,
      scheduleJson: scheduleJson ?? this.scheduleJson,
      savedAt: savedAt ?? this.savedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduleJson': scheduleJson,
      'savedAt': savedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory SavedSchedule.fromJson(Map<String, dynamic> json) {
    return SavedSchedule(
      id: json['id'] as String,
      scheduleJson: json['scheduleJson'] as String,
      savedAt: DateTime.parse(json['savedAt'] as String),
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}
