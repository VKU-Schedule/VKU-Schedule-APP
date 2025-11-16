/// Session model representing a class meeting time
/// Matches the backend API response structure for schedule sessions
class Session {
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

  Session({
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

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      courseName: json['course_name'] as String? ?? json['courseName'] as String,
      teacher: json['teacher'] as String,
      day: json['day'] as String,
      periods: (json['periods'] as List<dynamic>)
          .map((p) => p as int)
          .toList(),
      room: json['room'] as String,
      area: json['area'] as String,
      classIndex: json['class_index'] as int? ?? json['classIndex'] as int,
      classSize: json['class_size'] as int? ?? json['classSize'] as int,
      language: json['language'] as String,
      field: json['field'] as String,
      subTopic: json['sub_topic'] as String? ?? json['subTopic'] as String,
    );
  }

  /// Create Session from ApiSession
  factory Session.fromApiSession(dynamic apiSession) {
    return Session(
      courseName: apiSession.courseName as String,
      teacher: apiSession.teacher as String,
      day: apiSession.day as String,
      periods: List<int>.from(apiSession.periods as List<dynamic>),
      room: apiSession.room as String,
      area: apiSession.area as String,
      classIndex: apiSession.classIndex as int,
      classSize: apiSession.classSize as int,
      language: apiSession.language as String,
      field: apiSession.field as String,
      subTopic: apiSession.subTopic as String,
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

  /// Check if this session overlaps with another session
  bool overlapsWith(Session other) {
    if (day != other.day) return false;
    // Check if any period overlaps
    return periods.any((p) => other.periods.contains(p));
  }

  /// Get the day name in Vietnamese
  /// Supports both English (Monday) and Vietnamese (Thứ Hai) input
  String get dayName {
    // If already in Vietnamese, return as is
    if (day.contains('Thứ') || day.contains('Chủ nhật')) {
      return day;
    }
    
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

  /// Get day index (0 = Monday, 6 = Sunday)
  /// Supports both English and Vietnamese day names
  int get dayIndex {
    final dayLower = day.toLowerCase();
    
    // Vietnamese days
    if (dayLower.contains('thứ hai') || dayLower == 'thứ 2') return 0;
    if (dayLower.contains('thứ ba') || dayLower == 'thứ 3') return 1;
    if (dayLower.contains('thứ tư') || dayLower == 'thứ 4') return 2;
    if (dayLower.contains('thứ năm') || dayLower == 'thứ 5') return 3;
    if (dayLower.contains('thứ sáu') || dayLower == 'thứ 6') return 4;
    if (dayLower.contains('thứ bảy') || dayLower == 'thứ 7') return 5;
    if (dayLower.contains('chủ nhật') || dayLower == 'cn') return 6;
    
    // English days
    if (dayLower == 'monday') return 0;
    if (dayLower == 'tuesday') return 1;
    if (dayLower == 'wednesday') return 2;
    if (dayLower == 'thursday') return 3;
    if (dayLower == 'friday') return 4;
    if (dayLower == 'saturday') return 5;
    if (dayLower == 'sunday') return 6;
    
    return 0; // Default to Monday
  }

  /// Get formatted period range (e.g., "Tiết 1-3")
  String get periodRange {
    if (periods.isEmpty) return '';
    if (periods.length == 1) return 'Tiết ${periods.first}';
    final sorted = List<int>.from(periods)..sort();
    return 'Tiết ${sorted.first}-${sorted.last}';
  }

  /// Get the start period (earliest period)
  int get startPeriod {
    if (periods.isEmpty) return 0;
    return periods.reduce((a, b) => a < b ? a : b);
  }

  /// Get the end period (latest period)
  int get endPeriod {
    if (periods.isEmpty) return 0;
    return periods.reduce((a, b) => a > b ? a : b);
  }

  // Convenience getters for compatibility with other code
  int get start => startPeriod;
  int get end => endPeriod;
  String get subjectId => '$courseName-$subTopic';
  String get instructor => teacher;
  String get group => 'N${classIndex}'; // Generate group name from classIndex

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Session &&
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
      'Session(courseName: $courseName, teacher: $teacher, day: $day, periods: $periods)';
}


