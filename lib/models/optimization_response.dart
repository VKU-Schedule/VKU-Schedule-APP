import 'api_schedule_option.dart';

/// Response model for schedule optimization API
/// Received from the backend server after NSGA-II optimization
class OptimizationResponse {
  final String message;
  final List<ApiScheduleOption> schedules;

  OptimizationResponse({
    required this.message,
    required this.schedules,
  });

  factory OptimizationResponse.fromJson(Map<String, dynamic> json) {
    return OptimizationResponse(
      message: json['message'] as String,
      schedules: (json['schedules'] as List<dynamic>)
          .map((s) => ApiScheduleOption.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'schedules': schedules.map((s) => s.toJson()).toList(),
    };
  }

  /// Check if the response contains valid schedules
  bool get hasSchedules => schedules.isNotEmpty;

  /// Get the number of schedule options returned
  int get scheduleCount => schedules.length;

  @override
  String toString() =>
      'OptimizationResponse(message: $message, schedules: ${schedules.length})';
}
