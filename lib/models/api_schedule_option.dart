import 'api_session.dart';

/// Represents a single schedule entry in the optimization response
/// This is an alias for ApiSession for clarity in the schedule context
typedef ScheduleEntry = ApiSession;

/// API-compatible ScheduleOption model for optimization results
/// This model matches the backend API response structure
class ApiScheduleOption {
  final String id;
  final List<ScheduleEntry> schedule;
  final double score;

  ApiScheduleOption({
    String? id,
    required this.schedule,
    required this.score,
  }) : id = id ?? _generateId();

  factory ApiScheduleOption.fromJson(Map<String, dynamic> json) {
    final scheduleData = json['schedule'] as List<dynamic>;
    
    // Parse schedule - server returns [[course_name, session_data], ...]
    final sessions = scheduleData.map((item) {
      if (item is List && item.length >= 2) {
        // item[0] is course name (string), item[1] is session data (map)
        return ApiSession.fromJson(item[1] as Map<String, dynamic>);
      } else if (item is Map<String, dynamic>) {
        // Fallback: if it's already a map, parse directly
        return ApiSession.fromJson(item);
      } else {
        throw FormatException('Invalid schedule item format');
      }
    }).toList();
    
    return ApiScheduleOption(
      id: json['id'] as String?,
      schedule: sessions,
      score: (json['score'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schedule': schedule.map((s) => s.toJson()).toList(),
      'score': score,
    };
  }

  /// Get total number of sessions in this schedule
  int get totalSessions => schedule.length;

  /// Get unique subjects in this schedule
  Set<String> get uniqueSubjects =>
      schedule.map((s) => s.courseName).toSet();

  /// Get sessions grouped by day
  Map<String, List<ScheduleEntry>> get sessionsByDay {
    final Map<String, List<ScheduleEntry>> grouped = {};
    for (final session in schedule) {
      grouped.putIfAbsent(session.day, () => []).add(session);
    }
    return grouped;
  }

  /// Get number of free days (days with no classes)
  int get freeDays {
    const allDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final scheduledDays = schedule.map((s) => s.day).toSet();
    return allDays.length - scheduledDays.length;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApiScheduleOption && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ApiScheduleOption(id: $id, sessions: ${schedule.length}, score: $score)';

  /// Generate a unique ID for local identification
  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.hashCode;
    return 'schedule_${timestamp}_$random';
  }
}
