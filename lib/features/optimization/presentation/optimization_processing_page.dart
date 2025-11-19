import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/vku_loading_animation.dart';
import '../../../core/widgets/loading_content.dart';
import '../../../core/widgets/error_states.dart';
import '../../../core/widgets/success_celebration.dart';
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
  int _currentStep = 0;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    // Delay optimization to avoid modifying provider during widget build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startOptimization();
      _simulateProgress();
    });
  }

  void _simulateProgress() {
    // Simulate progress for better UX
    const steps = [
      'Đang phân tích môn học...',
      'Đang xử lý ràng buộc...',
      'Đang tối ưu hóa...',
      'Đang tạo phương án...',
    ];

    for (var i = 0; i < steps.length; i++) {
      Future.delayed(Duration(seconds: i * 10), () {
        if (mounted && !_isCancelled) {
          setState(() {
            _currentStep = i;
            _progress = (i + 1) / steps.length;
          });
        }
      });
    }
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
      // Navigation is now handled by the success celebration widget
      print('[Optimization] Success state will show celebration and auto-navigate');
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
      appBar: VKUAppBar(
        title: 'Đang tối ưu lịch học',
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _isCancelled = true;
            });
            context.go('/subjects');
          },
          tooltip: 'Hủy',
          color: Colors.white,
        ),
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: optimizationAsync.when(
            data: (options) => _buildSuccessState(context, options.length),
            loading: () => _buildLoadingState(context),
            error: (error, stack) => _buildErrorState(context, error),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    const steps = [
      'Đang phân tích môn học...',
      'Đang xử lý ràng buộc...',
      'Đang tối ưu hóa...',
      'Đang tạo phương án...',
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          children: [
            const SizedBox(height: AppTheme.spaceXl),
            
            // VKU Logo Animation with particle effects
            Stack(
              alignment: Alignment.center,
              children: [
                const ParticleEffect(
                  particleCount: 20,
                  size: 300,
                ),
                const VKULogoAnimation(size: 120),
              ],
            ),
            
            const SizedBox(height: AppTheme.space2xl),
            
            // Title
            Text(
              'Đang tối ưu lịch học',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.vkuNavy,
                  ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppTheme.spaceSm),
            
            // Countdown timer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time,
                  size: 20,
                  color: AppTheme.textLight,
                ),
                const SizedBox(width: AppTheme.spaceSm),
                const CountdownTimer(totalSeconds: 60),
              ],
            ),
            
            const SizedBox(height: AppTheme.space2xl),
            
            // Gradient progress bar
            VKUGradientProgressBar(
              progress: _progress,
              height: 12,
              borderRadius: 6,
            ),
            
            const SizedBox(height: AppTheme.spaceLg),
            
            // Progress steps
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                boxShadow: AppTheme.subtleShadows,
              ),
              child: ProgressSteps(
                currentStep: _currentStep,
                steps: steps,
              ),
            ),
            
            const SizedBox(height: AppTheme.space2xl),
            
            // Fun facts carousel
            const FunFactsCarousel(),
            
            const SizedBox(height: AppTheme.spaceLg),
            
            // Tips carousel
            const TipsCarousel(),
            
            const SizedBox(height: AppTheme.spaceLg),
            
            // Optional mini game
            const VKUCoinGame(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context, int optionsCount) {
    return SuccessCelebration(
      title: 'Hoàn thành!',
      subtitle: 'Đã tạo $optionsCount phương án tối ưu',
      celebrationDuration: const Duration(seconds: 2),
      onComplete: () {
        // Navigate to options page after celebration
        if (mounted && !_isCancelled) {
          context.go('/options');
        }
      },
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    final errorType = getErrorTypeFromException(error);
    
    return VKUErrorState(
      errorType: errorType,
      customMessage: _getFriendlyErrorMessage(error),
      showOfflineIndicator: errorType == ErrorType.network,
      onRetry: () {
        // Reset state and retry
        setState(() {
          _isCancelled = false;
          _currentStep = 0;
          _progress = 0.0;
        });
        _startOptimization();
        _simulateProgress();
      },
      onSupport: () {
        // Show support dialog or navigate to support page
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Liên hệ hỗ trợ'),
            content: const Text(
              'Nếu vấn đề vẫn tiếp diễn, vui lòng liên hệ:\n\n'
              'Email: support@vku.edu.vn\n'
              'Hotline: 1900-xxxx',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getFriendlyErrorMessage(Object error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('socket') || errorString.contains('network')) {
      return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối internet.';
    } else if (errorString.contains('timeout')) {
      return 'Quá trình tối ưu mất quá nhiều thời gian. Vui lòng thử lại.';
    } else if (errorString.contains('empty') || errorString.contains('no subjects')) {
      return 'Vui lòng chọn ít nhất một môn học trước khi tối ưu.';
    } else {
      return 'Đã xảy ra lỗi trong quá trình tối ưu hóa. Vui lòng thử lại.';
    }
  }
}


