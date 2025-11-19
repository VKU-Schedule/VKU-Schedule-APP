import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class HeroSection extends StatelessWidget {
  final AnimationController animationController;
  final VoidCallback onGetStarted;

  const HeroSection({
    super.key,
    required this.animationController,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        gradient: AppTheme.gradientRedToNavy,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          // Animated Grid Pattern
          Positioned.fill(
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: GridPatternPainter(
                    animation: animationController.value,
                  ),
                );
              },
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppTheme.spaceMd),

                // VKU Logo Animation
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animationController,
                    curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
                  ),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.5),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animationController,
                        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.school,
                            color: AppTheme.vkuRed,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spaceMd),
                        const Text(
                          'VKU Schedule',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Welcome Message with Gradient Text Effect
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animationController,
                    curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
                  ),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animationController,
                        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.white, AppTheme.vkuYellow],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: const Text(
                            'Xin chào!',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceSm),
                        Text(
                          'Cá nhân hóa lịch học của bạn',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.spaceLg),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GridPatternPainter extends CustomPainter {
  final double animation;

  GridPatternPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const gridSize = 40.0;
    final offset = animation * gridSize;

    // Draw vertical lines
    for (double x = -gridSize + offset; x < size.width + gridSize; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = -gridSize + offset; y < size.height + gridSize; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw diagonal accent lines
    final accentPaint = Paint()
      ..color = AppTheme.vkuYellow.withValues(alpha: 0.1)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final diagonalOffset = animation * gridSize * 2;
    for (double i = -size.width + diagonalOffset;
        i < size.width + size.height;
        i += gridSize * 3) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        accentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPatternPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
