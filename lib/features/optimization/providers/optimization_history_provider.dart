import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/optimization_history.dart';
import '../../../models/schedule_option.dart';
import '../../../services/local_storage_service.dart';
import '../../../core/di/providers.dart';

final optimizationHistoryProvider =
    StateNotifierProvider<OptimizationHistoryNotifier, List<OptimizationHistory>>(
  (ref) {
    final localStorage = ref.watch(localStorageServiceProvider);
    return OptimizationHistoryNotifier(localStorage);
  },
);

class OptimizationHistoryNotifier extends StateNotifier<List<OptimizationHistory>> {
  final LocalStorageService _localStorage;

  OptimizationHistoryNotifier(this._localStorage) : super([]) {
    _loadHistory();
  }

  void _loadHistory() {
    try {
      state = _localStorage.getOptimizationHistory();
    } catch (e) {
      print('[OptimizationHistoryNotifier] Error loading history: $e');
      state = [];
    }
  }

  /// Save a new optimization run to history
  Future<void> saveOptimizationRun(List<ScheduleOption> options, {String? query}) async {
    try {
      final historyId = DateTime.now().millisecondsSinceEpoch.toString();
      final history = OptimizationHistory(
        id: historyId,
        createdAt: DateTime.now(),
        scheduleOptionIds: options.map((o) => o.id).toList(),
        query: query,
      );

      await _localStorage.saveOptimizationHistory(history);
      
      // Also save all schedule options to a temporary storage for this run
      for (final option in options) {
        await _localStorage.saveScheduleOptionForHistory(historyId, option);
      }

      _loadHistory();
    } catch (e) {
      print('[OptimizationHistoryNotifier] Error saving history: $e');
      rethrow;
    }
  }

  /// Get schedule options for a specific history run
  List<ScheduleOption> getScheduleOptionsForHistory(String historyId) {
    try {
      return _localStorage.getScheduleOptionsForHistory(historyId);
    } catch (e) {
      print('[OptimizationHistoryNotifier] Error getting options: $e');
      return [];
    }
  }

  /// Delete a history entry
  Future<void> deleteHistory(String historyId) async {
    try {
      await _localStorage.deleteOptimizationHistory(historyId);
      _loadHistory();
    } catch (e) {
      print('[OptimizationHistoryNotifier] Error deleting history: $e');
      rethrow;
    }
  }
}

