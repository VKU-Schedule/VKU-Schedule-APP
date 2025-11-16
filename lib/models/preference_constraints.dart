class PreferenceConstraints {
  final bool morningPreferred;
  final List<int> noDays; // Days to avoid (0-6)
  final List<TimeWindow> timeWindows;
  final List<String> avoidInstructors;
  final int? maxConsecutivePeriods;
  final int? minRestInterval;
  final String? rawPromptText; // Raw text input from user

  PreferenceConstraints({
    this.morningPreferred = false,
    this.noDays = const [],
    this.timeWindows = const [],
    this.avoidInstructors = const [],
    this.maxConsecutivePeriods,
    this.minRestInterval,
    this.rawPromptText,
  });

  factory PreferenceConstraints.fromJson(Map<String, dynamic> json) {
    return PreferenceConstraints(
      morningPreferred: json['morningPreferred'] as bool? ?? false,
      noDays: (json['noDays'] as List<dynamic>?)
              ?.map((d) => d as int)
              .toList() ??
          [],
      timeWindows: (json['timeWindows'] as List<dynamic>?)
              ?.map((tw) => TimeWindow.fromJson(tw as Map<String, dynamic>))
              .toList() ??
          [],
      avoidInstructors: (json['avoidInstructors'] as List<dynamic>?)
              ?.map((i) => i as String)
              .toList() ??
          [],
      maxConsecutivePeriods: json['maxConsecutivePeriods'] as int?,
      minRestInterval: json['minRestInterval'] as int?,
      rawPromptText: json['rawPromptText'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'morningPreferred': morningPreferred,
      'noDays': noDays,
      'timeWindows': timeWindows.map((tw) => tw.toJson()).toList(),
      'avoidInstructors': avoidInstructors,
      'maxConsecutivePeriods': maxConsecutivePeriods,
      'minRestInterval': minRestInterval,
      'rawPromptText': rawPromptText,
    };
  }

  PreferenceConstraints copyWith({
    bool? morningPreferred,
    List<int>? noDays,
    List<TimeWindow>? timeWindows,
    List<String>? avoidInstructors,
    int? maxConsecutivePeriods,
    int? minRestInterval,
    String? rawPromptText,
  }) {
    return PreferenceConstraints(
      morningPreferred: morningPreferred ?? this.morningPreferred,
      noDays: noDays ?? this.noDays,
      timeWindows: timeWindows ?? this.timeWindows,
      avoidInstructors: avoidInstructors ?? this.avoidInstructors,
      maxConsecutivePeriods: maxConsecutivePeriods ?? this.maxConsecutivePeriods,
      minRestInterval: minRestInterval ?? this.minRestInterval,
      rawPromptText: rawPromptText ?? this.rawPromptText,
    );
  }
}

class TimeWindow {
  final int day;
  final int start;
  final int end;

  TimeWindow({
    required this.day,
    required this.start,
    required this.end,
  });

  factory TimeWindow.fromJson(Map<String, dynamic> json) {
    return TimeWindow(
      day: json['day'] as int,
      start: json['start'] as int,
      end: json['end'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'start': start,
      'end': end,
    };
  }
}


