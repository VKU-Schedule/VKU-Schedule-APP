import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Success celebration widget with confetti and animations
class SuccessCelebration extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onComplete;
  final Duration celebrationDuration;

  const SuccessCelebration({
    super.key,
    required this.title,
    required this.subtitle,
    this.onComplete,
    this.celebrationDuration = const Duration(seconds: 2),
  });

  @override
  State<SuccessCelebration> createState() => _SuccessCelebrationState();
}

class _SuccessCelebrationState extends State<SuccessCelebration>
    with TickerProviderStateMixin {
  late AnimationController _checkmarkController;
  late AnimationController _confettiController;
  late AnimationController _textController;

  late Animation<double> _checkmarkScaleAnimation;
  late Animation<double> _checkmarkRotationAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Checkmark animation
    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _checkmarkScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _checkmarkController,
      curve: Curves.elasticOut,
    ));

    _checkmarkRotationAnimation = Tween<double>(
      begin: -0.5,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _checkmarkController,
      curve: Curves.easeOut,
    ));

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Text animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Start checkmark animation
    await _checkmarkController.forward();

    // Haptic feedback for success
    HapticFeedback.heavyImpact();

    // Start confetti
    _confettiController.forward();

    // Start text animation
    await Future.delayed(const Duration(milliseconds: 200));
    _textController.forward();

    // Call onComplete after celebration duration
    await Future.delayed(widget.celebrationDuration);
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _checkmarkController.dispose();
    _confettiController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Confetti layer
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                painter: ConfettiPainter(
                  progress: _confettiController.value,
                ),
              );
            },
          ),
        ),

        // Content layer
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated checkmark
              AnimatedBuilder(
                animation: _checkmarkController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _checkmarkScaleAnimation.value,
                    child: Transform.rotate(
                      angle: _checkmarkRotationAnimation.value,
                      child: const AnimatedCheckmark(),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppTheme.spaceLg),

              // Animated text
              FadeTransition(
                opacity: _textFadeAnimation,
                child: SlideTransition(
                  position: _textSlideAnimation,
                  child: Column(
                    children: [
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.vkuNavy,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spaceMd),
                      Text(
                        widget.subtitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textMedium,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Animated checkmark with scale effect
class AnimatedCheckmark extends StatefulWidget {
  const AnimatedCheckmark({super.key});

  @override
  State<AnimatedCheckmark> createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<AnimatedCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.vkuYellow.withValues(alpha: 0.2),
                  AppTheme.vkuYellow.withValues(alpha: 0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.vkuYellow.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.vkuYellow,
                    AppTheme.vkuYellow800,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.check,
                size: 64,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Confetti painter with VKU colors
class ConfettiPainter extends CustomPainter {
  final double progress;
  final List<ConfettiParticle> particles;

  ConfettiPainter({required this.progress})
      : particles = _generateParticles();

  static List<ConfettiParticle> _generateParticles() {
    final random = math.Random();
    return List.generate(50, (index) {
      return ConfettiParticle(
        color: _getVKUColor(index),
        startX: 0.5 + (random.nextDouble() - 0.5) * 0.2,
        startY: 0.4,
        velocityX: (random.nextDouble() - 0.5) * 2,
        velocityY: -random.nextDouble() * 3 - 2,
        rotation: random.nextDouble() * math.pi * 2,
        rotationSpeed: (random.nextDouble() - 0.5) * 4,
        size: random.nextDouble() * 8 + 4,
        shape: random.nextInt(3), // 0: square, 1: circle, 2: triangle
      );
    });
  }

  static Color _getVKUColor(int index) {
    final colors = [
      AppTheme.vkuRed,
      AppTheme.vkuYellow,
      AppTheme.vkuNavy,
      AppTheme.vkuRed300,
      AppTheme.vkuYellow300,
      AppTheme.vkuNavy300,
    ];
    return colors[index % colors.length];
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final x = particle.startX * size.width +
          particle.velocityX * progress * size.width * 0.3;
      final y = particle.startY * size.height +
          particle.velocityY * progress * size.height * 0.5 +
          0.5 * 9.8 * progress * progress * size.height * 0.5; // Gravity

      final rotation = particle.rotation + particle.rotationSpeed * progress;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      final paint = Paint()
        ..color = particle.color.withValues(
          alpha: (1.0 - progress * 0.5),
        )
        ..style = PaintingStyle.fill;

      switch (particle.shape) {
        case 0: // Square
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size,
            ),
            paint,
          );
          break;
        case 1: // Circle
          canvas.drawCircle(
            Offset.zero,
            particle.size / 2,
            paint,
          );
          break;
        case 2: // Triangle
          final path = Path()
            ..moveTo(0, -particle.size / 2)
            ..lineTo(particle.size / 2, particle.size / 2)
            ..lineTo(-particle.size / 2, particle.size / 2)
            ..close();
          canvas.drawPath(path, paint);
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class ConfettiParticle {
  final Color color;
  final double startX;
  final double startY;
  final double velocityX;
  final double velocityY;
  final double rotation;
  final double rotationSpeed;
  final double size;
  final int shape;

  ConfettiParticle({
    required this.color,
    required this.startX,
    required this.startY,
    required this.velocityX,
    required this.velocityY,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.shape,
  });
}

/// Simple success animation without confetti (for less dramatic effect)
class SimpleSuccessAnimation extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const SimpleSuccessAnimation({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.check_circle,
  });

  @override
  State<SimpleSuccessAnimation> createState() => _SimpleSuccessAnimationState();
}

class _SimpleSuccessAnimationState extends State<SimpleSuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.gradientYellowSubtle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.vkuYellow.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  size: 64,
                  color: AppTheme.vkuYellow800,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.vkuNavy,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              widget.subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textMedium,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
