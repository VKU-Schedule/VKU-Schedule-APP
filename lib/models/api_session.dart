/// API-compatible Session model for schedule optimization
/// This model matches the backend API response structure
class ApiSession {
  final String courseName;
  final String teacher;
  final String day;
  final List<int> periods;
  final String room;
  final String area;
  final int classIndex;
  final int classSize;
  final String language;
  final String field;
  final String subTopic;

  ApiSession({
    required this.courseName,
    required this.teacher,
    required this.day,
    required this.periods,
    required this.room,
    required this.area,
    required this.classIndex,
    required this.classSize,
    required this.language,
    required this.field,
    required this.subTopic,
  });

  factory ApiSession.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert num (int or double) to int
    int _toInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is num) return value.toInt();
      throw FormatException('Cannot convert $value to int');
    }

    return ApiSession(
      courseName: json['course_name'] as String? ?? json['courseName'] as String,
      teacher: json['teacher'] as String,
      day: json['day'] as String,
      periods: (json['periods'] as List<dynamic>)
          .map((p) => _toInt(p))
          .toList(),
      room: json['room'] as String,
      area: json['area'] as String,
      classIndex: _toInt(json['class_index'] ?? json['classIndex']),
      classSize: _toInt(json['class_size'] ?? json['classSize']),
      language: json['language'] as String,
      field: json['field'] as String,
      subTopic: json['sub_topic'] as String? ?? json['subTopic'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_name': courseName,
      'teacher': teacher,
      'day': day,
      'periods': periods,
      'room': room,
      'area': area,
      'class_index': classIndex,
      'class_size': classSize,
      'language': language,
      'field': field,
      'sub_topic': subTopic,
    };
  }

  /// Get the day name in Vietnamese
  String get dayNameVietnamese {
    const dayMap = {
      'Monday': 'Thứ Hai',
      'Tuesday': 'Thứ Ba',
      'Wednesday': 'Thứ Tư',
      'Thursday': 'Thứ Năm',
      'Friday': 'Thứ Sáu',
      'Saturday': 'Thứ Bảy',
      'Sunday': 'Chủ Nhật',
    };
    return dayMap[day] ?? day;
  }

  /// Get formatted period range (e.g., "Tiết 1-3")
  String get periodRange {
    if (periods.isEmpty) return '';
    if (periods.length == 1) return 'Tiết ${periods.first}';
    final sorted = List<int>.from(periods)..sort();
    return 'Tiết ${sorted.first}-${sorted.last}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApiSession &&
        other.courseName == courseName &&
        other.teacher == teacher &&
        other.day == day &&
        other.room == room &&
        other.classIndex == classIndex;
  }

  @override
  int get hashCode =>
      courseName.hashCode ^
      teacher.hashCode ^
      day.hashCode ^
      room.hashCode ^
      classIndex.hashCode;

  @override
  String toString() =>
      'ApiSession(courseName: $courseName, teacher: $teacher, day: $day, periods: $periods)';
}
