/// API-compatible Subject model for search and selection
/// This model matches the backend API response structure
class ApiSubject {
  final String courseName;
  final String subTopic;

  ApiSubject({
    required this.courseName,
    required this.subTopic,
  });

  factory ApiSubject.fromJson(Map<String, dynamic> json) {
    return ApiSubject(
      courseName: json['course_name'] as String? ?? json['courseName'] as String,
      subTopic: json['sub_topic'] as String? ?? json['subTopic'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_name': courseName,
      'sub_topic': subTopic,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApiSubject &&
        other.courseName == courseName &&
        other.subTopic == subTopic;
  }

  @override
  int get hashCode => courseName.hashCode ^ subTopic.hashCode;

  @override
  String toString() => 'ApiSubject(courseName: $courseName, subTopic: $subTopic)';
}
