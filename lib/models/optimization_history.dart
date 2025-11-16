class OptimizationHistory {
  String id;
  DateTime createdAt;
  List<String> scheduleOptionIds; // IDs of ScheduleOptions in this run
  String? query; // Search query or description

  OptimizationHistory({
    required this.id,
    required this.createdAt,
    required this.scheduleOptionIds,
    this.query,
  });

  OptimizationHistory copyWith({
    String? id,
    DateTime? createdAt,
    List<String>? scheduleOptionIds,
    String? query,
  }) {
    return OptimizationHistory(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      scheduleOptionIds: scheduleOptionIds ?? this.scheduleOptionIds,
      query: query ?? this.query,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'scheduleOptionIds': scheduleOptionIds,
      'query': query,
    };
  }

  factory OptimizationHistory.fromJson(Map<String, dynamic> json) {
    return OptimizationHistory(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      scheduleOptionIds: List<String>.from(json['scheduleOptionIds'] as List),
      query: json['query'] as String?,
    );
  }
}

