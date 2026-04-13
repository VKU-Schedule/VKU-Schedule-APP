import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/preference_constraints.dart';
import '../../../models/schedule_option.dart';
import '../../../models/subject.dart';
import '../../../models/weights.dart';
import '../../../services/optimization_service.dart';
import '../providers/optimization_history_provider.dart';

// Provider to track if optimization is currently running
final isOptimizingProvider = StateProvider<bool>((ref) => false);

final optimizationProvider =
    AsyncNotifierProvider<OptimizationNotifier, List<ScheduleOption>>(
  () => OptimizationNotifier(),
);

class OptimizationNotifier extends AsyncNotifier<List<ScheduleOption>> {
  @override
  Future<List<ScheduleOption>> build() async {
    return [];
  }

  Future<void> optimize({
    required List<Subject> selectedSubjects,
    required PreferenceConstraints constraints,
    required Weights weights,
    required OptimizationService service,
    required bool Function() onCancelled,
  }) async {
    print('[OptimizationNotifier] optimize() called');
    print('[OptimizationNotifier] Service: ${service.runtimeType}');
    print('[OptimizationNotifier] Subjects: ${selectedSubjects.length}');

    // Set optimizing flag
    ref.read(isOptimizingProvider.notifier).state = true;

    try {
      print('[OptimizationNotifier] Calling service.optimize()...');
      final options = await service.optimize(
        selectedSubjects: selectedSubjects,
        constraints: constraints,
        weights: weights,
      );

      print('[OptimizationNotifier] Service returned ${options.length} options');

      if (onCancelled()) {
        print('[OptimizationNotifier] Optimization was cancelled');
        ref.read(isOptimizingProvider.notifier).state = false;
        return;
      }

      print('[OptimizationNotifier] Setting state to data');
      state = AsyncValue.data(options);

      // Clear optimizing flag
      ref.read(isOptimizingProvider.notifier).state = false;

      // Save to optimization history
      try {
        final historyNotifier = ref.read(optimizationHistoryProvider.notifier);
        await historyNotifier.saveOptimizationRun(options);
        print('[OptimizationNotifier] Saved to optimization history');
      } catch (e) {
        print('[OptimizationNotifier] Failed to save history: $e');
        // Don't fail the optimization if history save fails
      }
    } catch (error, stackTrace) {
      print('[OptimizationNotifier] ❌ Error occurred!');
      print('[OptimizationNotifier] Error: $error');
      print('[OptimizationNotifier] StackTrace: $stackTrace');
      
      // Clear optimizing flag
      ref.read(isOptimizingProvider.notifier).state = false;
      
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
