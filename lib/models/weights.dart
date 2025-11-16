class Weights {
  final int teacher;
  final int classGroup;
  final int day;
  final int consecutive;
  final int rest;
  final int room;

  Weights({
    this.teacher = 3,
    this.classGroup = 3,
    this.day = 3,
    this.consecutive = 3,
    this.rest = 3,
    this.room = 3,
  });

  factory Weights.fromJson(Map<String, dynamic> json) {
    return Weights(
      teacher: json['teacher'] as int? ?? 3,
      classGroup: json['classGroup'] as int? ?? 3,
      day: json['day'] as int? ?? 3,
      consecutive: json['consecutive'] as int? ?? 3,
      rest: json['rest'] as int? ?? 3,
      room: json['room'] as int? ?? 3,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacher': teacher,
      'classGroup': classGroup,
      'day': day,
      'consecutive': consecutive,
      'rest': rest,
      'room': room,
    };
  }

  Weights copyWith({
    int? teacher,
    int? classGroup,
    int? day,
    int? consecutive,
    int? rest,
    int? room,
  }) {
    return Weights(
      teacher: teacher ?? this.teacher,
      classGroup: classGroup ?? this.classGroup,
      day: day ?? this.day,
      consecutive: consecutive ?? this.consecutive,
      rest: rest ?? this.rest,
      room: room ?? this.room,
    );
  }
}


