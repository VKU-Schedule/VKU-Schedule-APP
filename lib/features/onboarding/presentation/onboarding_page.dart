import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/providers.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    const OnboardingSlide(
      title: 'Tối ưu lịch học của bạn',
      description: 'Sử dụng thuật toán NSGA-II để tạo ra nhiều phương án lịch học phù hợp nhất với bạn',
      icon: Icons.auto_awesome,
    ),
    const OnboardingSlide(
      title: 'Nhập sở thích bằng tiếng Việt',
      description: 'Mô tả sở thích của bạn bằng ngôn ngữ tự nhiên, AI sẽ tự động phân tích và tạo lịch',
      icon: Icons.chat_bubble_outline,
    ),
    const OnboardingSlide(
      title: 'So sánh và chọn lịch tốt nhất',
      description: 'Xem nhiều phương án, so sánh và chọn lịch học phù hợp nhất với bạn',
      icon: Icons.compare_arrows,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return _slides[index];
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => _buildDot(index),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_currentPage < _slides.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      // Save onboarding completion status
                      final localStorage = ref.read(localStorageServiceProvider);
                      await localStorage.updateSetting(
                        hasCompletedOnboarding: true,
                      );
                      
                      if (mounted) {
                        context.go('/subjects');
                      }
                    }
                  },
                  child: Text(
                    _currentPage < _slides.length - 1
                        ? 'Tiếp theo'
                        : 'Bắt đầu',
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Skip onboarding
                final localStorage = ref.read(localStorageServiceProvider);
                await localStorage.updateSetting(
                  hasCompletedOnboarding: true,
                );
                
                if (mounted) {
                  context.go('/subjects');
                }
              },
              child: const Text('Bỏ qua'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? Theme.of(context).colorScheme.primary
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingSlide extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const OnboardingSlide({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 120,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 48),
          Text(
            title,
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


