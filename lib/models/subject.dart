/// Subject model for search and selection
/// Represents a course that students can select for schedule optimization
class Subject {
  final String courseName;
  final String subTopic;
  final String? code;
  final int? credits;

  Subject({
    required this.courseName,
    required this.subTopic,
    this.code,
    this.credits,
  });

  // Convenience getters for UI compatibility
  String get name => courseName;
  String get id => '$courseName-$subTopic'; // Generate ID from courseName and subTopic

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      courseName: json['course_name'] as String? ?? json['courseName'] as String,
      subTopic: json['sub_topic'] as String? ?? json['subTopic'] as String,
      code: json['code'] as String?,
      credits: json['credits'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_name': courseName,
      'sub_topic': subTopic,
      if (code != null) 'code': code,
      if (credits != null) 'credits': credits,
    };
  }

  Subject copyWith({
    String? courseName,
    String? subTopic,
    String? code,
    int? credits,
  }) {
    return Subject(
      courseName: courseName ?? this.courseName,
      subTopic: subTopic ?? this.subTopic,
      code: code ?? this.code,
      credits: credits ?? this.credits,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Subject &&
        other.courseName == courseName &&
        other.subTopic == subTopic &&
        other.code == code &&
        other.credits == credits;
  }

  @override
  int get hashCode =>
      courseName.hashCode ^
      subTopic.hashCode ^
      (code?.hashCode ?? 0) ^
      (credits?.hashCode ?? 0);

  @override
  String toString() =>
      'Subject(courseName: $courseName, subTopic: $subTopic, code: $code, credits: $credits)';
}


