import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vku_schedule/models/user_profile.dart';
import 'package:vku_schedule/models/saved_schedule.dart';
import 'package:vku_schedule/models/app_settings.dart';
import 'package:vku_schedule/models/optimization_history.dart';
import 'package:vku_schedule/models/schedule_option.dart';

class LocalStorageService {
  static const String _userProfileBoxName = 'userProfile';
  static const String _savedSchedulesBoxName = 'savedSchedules';
  static const String _appSettingsBoxName = 'appSettings';
  static const String _optimizationHistoryBoxName = 'optimizationHistory';
  static const String _historyOptionsBoxName = 'historyOptions';

  Box<UserProfile>? _userProfileBox;
  Box<SavedSchedule>? _savedSchedulesBox;
  Box<AppSettings>? _appSettingsBox;
  Box<String>? _optimizationHistoryBox;
  Box<String>? _historyOptionsBox;

  /// Initialize Hive and open all boxes
  Future<void> initialize() async {
    try {
      // Initialize Hive
      await Hive.initFlutter();

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(UserProfileAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(SavedScheduleAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(AppSettingsAdapter());
      }

      // Open boxes
      _userProfileBox = await Hive.openBox<UserProfile>(_userProfileBoxName);
      _savedSchedulesBox = await Hive.openBox<SavedSchedule>(_savedSchedulesBoxName);
      _appSettingsBox = await Hive.openBox<AppSettings>(_appSettingsBoxName);
      _optimizationHistoryBox = await Hive.openBox<String>(_optimizationHistoryBoxName);
      _historyOptionsBox = await Hive.openBox<String>(_historyOptionsBoxName);
    } catch (e) {
      throw LocalStorageException('Failed to initialize local storage: $e');
    }
  }

  // ==================== User Profile Methods ====================

  /// Save user profile to local storage
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      if (_userProfileBox == null) {
        throw LocalStorageException('Storage not initialized');
      }
      await _userProfileBox!.put('current_user', profile);
    } catch (e) {
      throw LocalStorageException('Failed to save user profile: $e');
    }
  }

  /// Get user profile from local storage
  UserProfile? getUserProfile() {
    try {
      if (_userProfileBox == null) {
        throw LocalStorageException('Storage not initialized');
      }
      return _userProfileBox!.get('current_user');
    } catch (e) {
      throw LocalStorageException('Failed to get user profile: $e');
    }
  }

  /// Delete user profile from local storage
  Future<void> deleteUserProfile() async {
    try {
      if (_userProfileBox == null) {
        throw LocalStorageException('Storage not initialized');
      }
      await _userProfileBox!.delete('current_user');
    } catch (e) {
      throw LocalStorageException('Failed to delete user profile: $e');
    }
  }

  // ==================== Saved Schedules Methods ====================

  /// Save a schedule to local storage
  Future<void> saveSchedule(SavedSchedule schedule) async {
    try {
      if (_savedSchedulesBox == null) {
        throw LocalStorageException('Storage not initialized');
      }

      // If this schedule is marked as active, deactivate all others
      if (schedule.isActive) {
        await _deactivateAllSchedules();
      }

      await _savedSchedulesBox!.put(schedule.id, schedule);
    } catch (e) {
      throw LocalStorageException('Failed to save schedule: $e');
    }
  }

  /// Get all saved schedules from local storage
  List<SavedSchedule> getSavedSchedules() {
    try {
      if (_savedSchedulesBox == null) {
        throw LocalStorageException('Storage not initialized');
      }
      return _savedSchedulesBox!.values.toList();
    } catch (e) {
      throw LocalStorageException('Failed to get saved schedules: $e');
    }
  }

  /// Get a specific schedule by ID
  SavedSchedule? getScheduleById(String id) {
    try {
      if (_savedSchedulesBox == null) {
        throw LocalStorageException('Storage not initialized');
      }
      return _savedSchedulesBox!.get(id);
    } catch (e) {
      throw LocalStorageException('Failed to get schedule: $e');
    }
  }

  /// Get the currently active schedule
  SavedSchedule? getActiveSchedule() {
    try {
      if (_savedSchedulesBox == null) {
        throw LocalStorageException('Storage not initialized');
      }
      return _savedSchedulesBox!.values.firstWhere(
        (schedule) => schedule.isActive,
        orElse: () => throw StateError('No active schedule found'),
      );
    } catch (e) {
      if (e is StateError) {
        return null;
      }
      throw LocalStorageException('Failed to get active schedule: $e');
    }
  }

  /// Delete a schedule from local storage
  Future<void> deleteSchedule(String id) async {
    try {
      if (_savedSchedulesBox == null) {
        throw LocalStorageException('Storage not initialized');
      }
      await _savedSchedulesBox!.delete(id);
    } catch (e) {
      throw LocalStorageException('Failed to delete schedule: $e');
    }
  }

  /// Delete all saved schedules
  Future<void> deleteAllSchedules() async {
    try {
      if (_savedSchedulesBox == null) {
        throw LocalStorageException('Storage not initialized');
      }
      await _savedSchedulesBox!.clear();
    } catch (e) {
      throw LocalStorageException('Failed to delete all schedules: $e');
    }
  }

  /// Deactivate all schedules (helper method)
  Future<void> _deactivateAllSchedules() async {
    final schedules = _savedSchedulesBox!.values.toList();
    for (final schedule in schedules) {
      if (schedule.isActive) {
        schedule.isActive = false;
        await schedule.save();
      }
    }
  }

  // ==================== App Settings Methods ====================

  /// Save app settings to local storage
  Future<void> saveSettings(AppSettings settings) async {
    try {
      if (_appSettingsBox == null) {
        throw LocalStorageException('Storage not initialized');
      }
      await _appSettingsBox!.put('app_settings', settings);
    } catch (e) {
      throw LocalStorageException('Failed to save settings: $e');
    }
  }

  /// Get app settings from local storage
  AppSettings getSettings() {
    try {
      if (_appSettingsBox == null) {
        throw LocalStorageException('Storage not initialized');
      }
      return _appSettingsBox!.get('app_settings') ?? AppSettings();
    } catch (e) {
      throw LocalStorageException('Failed to get settings: $e');
    }
  }

  /// Update a specific setting
  Future<void> updateSetting({
    bool? hasCompletedOnboarding,
    String? themeMode,
    bool? notificationsEnabled,
  }) async {
    try {
      final currentSettings = getSettings();
      final updatedSettings = currentSettings.copyWith(
        hasCompletedOnboarding: hasCompletedOnboarding,
        themeMode: themeMode,
        notificationsEnabled: notificationsEnabled,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw LocalStorageException('Failed to update setting: $e');
    }
  }

  // ==================== Utility Methods ====================

  /// Clear all data from local storage
  Future<void> clearAllData() async {
    try {
      await _userProfileBox?.clear();
      await _savedSchedulesBox?.clear();
      await _appSettingsBox?.clear();
      await _optimizationHistoryBox?.clear();
      await _historyOptionsBox?.clear();
    } catch (e) {
      throw LocalStorageException('Failed to clear all data: $e');
    }
  }

  /// Close all boxes
  Future<void> close() async {
    try {
      await _userProfileBox?.close();
      await _savedSchedulesBox?.close();
      await _appSettingsBox?.close();
      await _optimizationHistoryBox?.close();
      await _historyOptionsBox?.close();
    } catch (e) {
      throw LocalStorageException('Failed to close storage: $e');
    }
  }

  /// Check if storage is initialized
  bool get isInitialized =>
      _userProfileBox != null &&
      _savedSchedulesBox != null &&
      _appSettingsBox != null &&
      _optimizationHistoryBox != null &&
      _historyOptionsBox != null;

  // ==================== Optimization History Methods ====================

  /// Save optimization history
  Future<void> saveOptimizationHistory(OptimizationHistory history) async {
    try {
      if (_optimizationHistoryBox == null) {
        throw LocalStorageException('Storage not initialized');
      }
      final json = jsonEncode(history.toJson());
      await _optimizationHistoryBox!.put(history.id, json);
    } catch (e) {
      throw LocalStorageException('Failed to save optimization history: $e');
    }
  }

  /// Get all optimization history
  List<OptimizationHistory> getOptimizationHistory() {
    try {
      if (_optimizationHistoryBox == null) {
        throw LocalStorageException('Storage not initialized');
      }
      return _optimizationHistoryBox!.values
          .map((json) => OptimizationHistory.fromJson(jsonDecode(json)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by date, newest first
    } catch (e) {
      throw LocalStorageException('Failed to get optimization history: $e');
    }
  }

  /// Delete optimization history
  Future<void> deleteOptimizationHistory(String historyId) async {
    try {
      if (_optimizationHistoryBox == null) {
        throw LocalStorageException('Storage not initialized');
      }
      await _optimizationHistoryBox!.delete(historyId);
      // Also delete all associated schedule options
      if (_historyOptionsBox != null) {
        final keysToDelete = _historyOptionsBox!.keys
            .where((key) => key.toString().startsWith('${historyId}_'))
            .toList();
        for (final key in keysToDelete) {
          await _historyOptionsBox!.delete(key);
        }
      }
    } catch (e) {
      throw LocalStorageException('Failed to delete optimization history: $e');
    }
  }

  /// Save schedule option for a specific history run
  Future<void> saveScheduleOptionForHistory(String historyId, ScheduleOption option) async {
    try {
      if (_historyOptionsBox == null) {
        throw LocalStorageException('Storage not initialized');
      }
      final key = '${historyId}_${option.id}';
      final json = jsonEncode(option.toJson());
      await _historyOptionsBox!.put(key, json);
    } catch (e) {
      throw LocalStorageException('Failed to save schedule option for history: $e');
    }
  }

  /// Get schedule options for a specific history run
  List<ScheduleOption> getScheduleOptionsForHistory(String historyId) {
    try {
      if (_historyOptionsBox == null) {
        throw LocalStorageException('Storage not initialized');
      }
      return _historyOptionsBox!.keys
          .where((key) => key.toString().startsWith('${historyId}_'))
          .map((key) {
            final json = _historyOptionsBox!.get(key);
            if (json == null) return null;
            return ScheduleOption.fromJson(jsonDecode(json));
          })
          .whereType<ScheduleOption>()
          .toList();
    } catch (e) {
      throw LocalStorageException('Failed to get schedule options for history: $e');
    }
  }
}

/// Custom exception for local storage errors
class LocalStorageException implements Exception {
  final String message;

  LocalStorageException(this.message);

  @override
  String toString() => 'LocalStorageException: $message';
}
