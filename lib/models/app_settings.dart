import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 2)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool hasCompletedOnboarding;

  @HiveField(1)
  String themeMode;

  @HiveField(2)
  bool notificationsEnabled;

  AppSettings({
    this.hasCompletedOnboarding = false,
    this.themeMode = 'system',
    this.notificationsEnabled = true,
  });

  AppSettings copyWith({
    bool? hasCompletedOnboarding,
    String? themeMode,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'themeMode': themeMode,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
      themeMode: json['themeMode'] as String? ?? 'system',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    );
  }
}
