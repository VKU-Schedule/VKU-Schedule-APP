import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String email;

  @HiveField(2)
  String? studentId;

  @HiveField(3)
  String? photoUrl;

  UserProfile({
    required this.name,
    required this.email,
    this.studentId,
    this.photoUrl,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? studentId,
    String? photoUrl,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      studentId: studentId ?? this.studentId,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'studentId': studentId,
      'photoUrl': photoUrl,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      email: json['email'] as String,
      studentId: json['studentId'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }
}
