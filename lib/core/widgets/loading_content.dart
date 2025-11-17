import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Rotating fun facts carousel about VKU
class FunFactsCarousel extends StatefulWidget {
  const FunFactsCarousel({super.key});

  @override
  State<FunFactsCarousel> createState() => _FunFactsCarouselState();
}

class _FunFactsCarouselState extends State<FunFactsCarousel> {
  int _currentIndex = 0;
  
  static const List<FunFact> _facts = [
    FunFact(
      icon: Icons.school,
      text: 'VKU được thành lập năm 2008 với sự hợp tác giữa Việt Nam và Hàn Quốc',
      color: AppTheme.vkuRed,
    ),
    FunFact(
      icon: Icons.computer,
      text: 'VKU chuyên đào tạo về Công nghệ thông tin và Truyền thông',
      color: AppTheme.vkuYellow800,
    ),
    FunFact(
      icon: Icons.lightbulb,
      text: 'Thuật toán NSGA-II giúp tối ưu hóa nhiều mục tiêu cùng lúc',
      color: AppTheme.vkuNavy,
    ),
    FunFact(
      icon: Icons.schedule,
      text: 'Một lịch học tốt giúp bạn cân bằng giữa học tập và nghỉ ngơi',
      color: AppTheme.vkuRed,
    ),
    FunFact(
      icon: Icons.psychology,
      text: 'AI đang phân tích hàng nghìn khả năng để tìm lịch tốt nhất cho bạn',
      color: AppTheme.vkuYellow800,
    ),
    FunFact(
      icon: Icons.groups,
      text: 'VKU có môi trường học tập quốc tế với nhiều sinh viên nước ngoài',
      color: AppTheme.vkuNavy,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startRotation();
  }

  void _startRotation() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _facts.length;
        });
        _startRotation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: FunFactCard(
        key: ValueKey(_currentIndex),
        fact: _facts[_currentIndex],
      ),
    );
  }
}

class FunFact {
  final IconData icon;
  final String text;
  final Color color;

  const FunFact({
    required this.icon,
    required this.text,
    required this.color,
  });
}

class FunFactCard extends StatelessWidget {
  final FunFact fact;

  const FunFactCard({
    super.key,
    required this.fact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.subtleShadows,
        border: Border.all(
          color: fact.color.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            decoration: BoxDecoration(
              color: fact.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(
              fact.icon,
              color: fact.color,
              size: 32,
            ),
          ),
          const SizedBox(width: AppTheme.spaceMd),
          Expanded(
            child: Text(
              fact.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textDark,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tips carousel with smooth transitions
class TipsCarousel extends StatefulWidget {
  const TipsCarousel({super.key});

  @override
  State<TipsCarousel> createState() => _TipsCarouselState();
}

class _TipsCarouselState extends State<TipsCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<OptimizationTip> _tips = [
    OptimizationTip(
      title: 'Mẹo tối ưu hóa',
      description: 'Hãy ưu tiên các môn khó vào buổi sáng khi đầu óc tỉnh táo nhất',
      icon: Icons.wb_sunny,
      gradient: AppTheme.gradientRedToYellow,
    ),
    OptimizationTip(
      title: 'Cân bằng thời gian',
      description: 'Nên có ít nhất 1 ngày nghỉ trong tuần để phục hồi năng lượng',
      icon: Icons.balance,
      gradient: AppTheme.gradientYellowToNavy,
    ),
    OptimizationTip(
      title: 'Giảm khoảng trống',
      description: 'Lịch học liên tục giúp bạn tiết kiệm thời gian di chuyển',
      icon: Icons.compress,
      gradient: AppTheme.gradientRedToNavy,
    ),
    OptimizationTip(
      title: 'Chọn giảng viên',
      description: 'Ưu tiên giảng viên phù hợp với phong cách học của bạn',
      icon: Icons.person,
      gradient: AppTheme.gradientNavyToRed,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted && _pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _tips.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _tips.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSm),
                child: TipCard(tip: _tips[index]),
              );
            },
          ),
        ),
        const SizedBox(height: AppTheme.spaceMd),
        // Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_tips.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppTheme.vkuRed
                    : AppTheme.dividerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class OptimizationTip {
  final String title;
  final String description;
  final IconData icon;
  final Gradient gradient;

  const OptimizationTip({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}

class TipCard extends StatelessWidget {
  final OptimizationTip tip;

  const TipCard({
    super.key,
    required this.tip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        gradient: tip.gradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.mediumShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceSm),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(
                  tip.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: Text(
                  tip.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Text(
            tip.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}

/// Animated background gradient
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  AppTheme.vkuRed.withValues(alpha: 0.05),
                  AppTheme.vkuYellow.withValues(alpha: 0.05),
                  _controller.value,
                )!,
                Color.lerp(
                  AppTheme.vkuYellow.withValues(alpha: 0.05),
                  AppTheme.vkuNavy.withValues(alpha: 0.05),
                  _controller.value,
                )!,
                Color.lerp(
                  AppTheme.vkuNavy.withValues(alpha: 0.05),
                  AppTheme.vkuRed.withValues(alpha: 0.05),
                  _controller.value,
                )!,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Mini game - Tap to collect VKU coins (optional, simple implementation)
class VKUCoinGame extends StatefulWidget {
  const VKUCoinGame({super.key});

  @override
  State<VKUCoinGame> createState() => _VKUCoinGameState();
}

class _VKUCoinGameState extends State<VKUCoinGame> {
  int _score = 0;
  final List<FallingCoin> _coins = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _spawnCoins();
  }

  void _spawnCoins() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _coins.add(FallingCoin(
            id: DateTime.now().millisecondsSinceEpoch,
            x: _random.nextDouble() * 0.8 + 0.1,
            color: _getRandomVKUColor(),
          ));
          // Remove old coins
          _coins.removeWhere((coin) =>
              DateTime.now().millisecondsSinceEpoch - coin.id > 5000);
        });
        _spawnCoins();
      }
    });
  }

  Color _getRandomVKUColor() {
    final colors = [AppTheme.vkuRed, AppTheme.vkuYellow, AppTheme.vkuNavy];
    return colors[_random.nextInt(colors.length)];
  }

  void _collectCoin(FallingCoin coin) {
    setState(() {
      _coins.remove(coin);
      _score++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.subtleShadows,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nhấn để thu thập xu VKU!',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.vkuNavy,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceMd,
                  vertical: AppTheme.spaceSm,
                ),
                decoration: BoxDecoration(
                  gradient: AppTheme.gradientYellowSubtle,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.stars,
                      color: AppTheme.vkuYellow800,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_score',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppTheme.vkuYellow800,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Expanded(
            child: Stack(
              children: _coins.map((coin) {
                return AnimatedCoin(
                  coin: coin,
                  onTap: () => _collectCoin(coin),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class FallingCoin {
  final int id;
  final double x;
  final Color color;

  FallingCoin({
    required this.id,
    required this.x,
    required this.color,
  });
}

class AnimatedCoin extends StatefulWidget {
  final FallingCoin coin;
  final VoidCallback onTap;

  const AnimatedCoin({
    super.key,
    required this.coin,
    required this.onTap,
  });

  @override
  State<AnimatedCoin> createState() => _AnimatedCoinState();
}

class _AnimatedCoinState extends State<AnimatedCoin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.coin.x * 250,
          top: _controller.value * 150,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.coin.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.coin.color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.stars,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }
}
