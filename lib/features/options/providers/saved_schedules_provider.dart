import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/schedule_option.dart';
import '../../../models/saved_schedule.dart';
import '../../../services/local_storage_service.dart';
import '../../../core/di/providers.dart';

final savedSchedulesProvider =
    StateNotifierProvider<SavedSchedulesNotifier, List<SavedSchedule>>(
  (ref) {
    final localStorage = ref.watch(localStorageServiceProvider);
    return SavedSchedulesNotifier(localStorage);
  },
);

class SavedSchedulesNotifier extends StateNotifier<List<SavedSchedule>> {
  final LocalStorageService _localStorage;

  SavedSchedulesNotifier(this._localStorage) : super([]) {
    _loadSavedSchedules();
  }

  /// Load all saved schedules from local storage
  void _loadSavedSchedules() {
    try {
      state = _localStorage.getSavedSchedules();
    } catch (e) {
      print('[SavedSchedulesNotifier] Error loading saved schedules: $e');
      state = [];
    }
  }

  /// Save a schedule option to local storage
  Future<void> saveSchedule(ScheduleOption option) async {
    try {
      final scheduleJson = jsonEncode(option.toJson());
      final savedSchedule = SavedSchedule(
        id: option.id,
        scheduleJson: scheduleJson,
        savedAt: DateTime.now(),
        isActive: false,
      );

      await _localStorage.saveSchedule(savedSchedule);
      _loadSavedSchedules();
    } catch (e) {
      print('[SavedSchedulesNotifier] Error saving schedule: $e');
      rethrow;
    }
  }

  /// Delete a saved schedule by ID
  Future<void> deleteSchedule(String id) async {
    try {
      await _localStorage.deleteSchedule(id);
      _loadSavedSchedules();
    } catch (e) {
      print('[SavedSchedulesNotifier] Error deleting schedule: $e');
      rethrow;
    }
  }

  /// Check if a schedule is saved by ID
  bool isScheduleSaved(String id) {
    return state.any((saved) => saved.id == id);
  }

  /// Get a saved schedule by ID
  SavedSchedule? getScheduleById(String id) {
    try {
      return state.firstWhere(
        (saved) => saved.id == id,
        orElse: () => throw StateError('Schedule not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Convert a SavedSchedule back to ScheduleOption
  ScheduleOption? getScheduleOption(String id) {
    final saved = getScheduleById(id);
    if (saved == null) return null;

    try {
      final json = jsonDecode(saved.scheduleJson) as Map<String, dynamic>;
      return ScheduleOption.fromJson(json);
    } catch (e) {
      print('[SavedSchedulesNotifier] Error parsing schedule: $e');
      return null;
    }
  }

  /// Update an existing saved schedule
  Future<void> updateSchedule(String id, ScheduleOption updatedOption) async {
    try {
      final scheduleJson = jsonEncode(updatedOption.toJson());
      final savedSchedule = SavedSchedule(
        id: id, // Keep the same ID
        scheduleJson: scheduleJson,
        savedAt: DateTime.now(), // Update saved time
        isActive: false,
      );

      await _localStorage.saveSchedule(savedSchedule);
      _loadSavedSchedules();
    } catch (e) {
      print('[SavedSchedulesNotifier] Error updating schedule: $e');
      rethrow;
    }
  }

  /// Refresh saved schedules list
  void refresh() {
    _loadSavedSchedules();
  }
}
