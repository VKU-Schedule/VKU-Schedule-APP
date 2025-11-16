import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../features/subjects/providers/subject_selection_provider.dart';
import '../../../features/preferences/providers/preferences_provider.dart';
import '../../../features/weights/providers/weights_provider.dart';
import '../providers/optimization_provider.dart';

class OptimizationProcessingPage extends ConsumerStatefulWidget {
  const OptimizationProcessingPage({super.key});

  @override
  ConsumerState<OptimizationProcessingPage> createState() =>
      _OptimizationProcessingPageState();
}

class _OptimizationProcessingPageState
    extends ConsumerState<OptimizationProcessingPage> {
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    // Delay optimization to avoid modifying provider during widget build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startOptimization();
    });
  }

  Future<void> _startOptimization() async {
    final selection = ref.read(subjectSelectionProvider);
    final preferences = ref.read(preferencesProvider);
    final weights = ref.read(weightsProvider);

    print('[Optimization] Starting optimization...');
    print('[Optimization] Enrolled subjects count: ${selection.enrolledSubjects.length}');
    print('[Optimization] Enrolled subject IDs: ${selection.enrolledSubjects}');

    if (selection.enrolledSubjects.isEmpty) {
      print('[Optimization] ERROR: No enrolled subjects');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn ít nhất một môn học'),
          ),
        );
        context.go('/subjects');
      }
      return;
    }

    // Get selected subjects from cache
    final selectedSubjects = selection.getEnrolledSubjects();
    print('[Optimization] Selected subjects from cache: ${selectedSubjects.length}');
    for (var i = 0; i < selectedSubjects.length; i++) {
      print('[Optimization]   [$i] ${selectedSubjects[i].courseName} - ${selectedSubjects[i].subTopic}');
    }

    if (selectedSubjects.isEmpty) {
      print('[Optimization] ERROR: Cache is empty but IDs exist');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không tìm thấy thông tin môn học. Vui lòng chọn lại.'),
          ),
        );
        context.go('/subjects');
      }
      return;
    }

    try {
      print('[Optimization] Getting optimization service from provider...');
      final optimizationService = ref.read(optimizationServiceProvider);
      print('[Optimization] OptimizationService: ${optimizationService.runtimeType}');
      
      final notifier = ref.read(optimizationProvider.notifier);
      print('[Optimization] OptimizationNotifier: ${notifier.runtimeType}');

      print('[Optimization] Calling notifier.optimize()...');
      await notifier.optimize(
        selectedSubjects: selectedSubjects,
        constraints: preferences,
        weights: weights,
        service: optimizationService,
        onCancelled: () => _isCancelled,
      );

      print('[Optimization] Optimization completed successfully!');
      if (mounted && !_isCancelled) {
        print('[Optimization] Navigating to /options');
        context.go('/options');
      } else {
        print('[Optimization] Not navigating - cancelled: $_isCancelled, mounted: $mounted');
      }
    } catch (error, stackTrace) {
      print('[Optimization] ❌ ERROR in _startOptimization()!');
      print('[Optimization] Error: $error');
      print('[Optimization] StackTrace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $error'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final optimizationAsync = ref.watch(optimizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đang tối ưu lịch học'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _isCancelled = true;
            });
            context.go('/subjects');
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: optimizationAsync.when(
              data: (options) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 80,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Hoàn thành!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Đã tạo ${options.length} phương án',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                );
              },
              loading: () => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    'Đang xử lý...',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ước tính: 30-60 giây',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
              error: (error, stack) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Lỗi',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$error',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/subjects'),
                    child: const Text('Quay lại'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


