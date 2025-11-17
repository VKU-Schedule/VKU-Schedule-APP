import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animated VKU logo with grid pattern morphing effect
class VKULogoAnimation extends StatefulWidget {
  final double size;
  
  const VKULogoAnimation({
    super.key,
    this.size = 120.0,
  });

  @override
  State<VKULogoAnimation> createState() => _VKULogoAnimationState();
}

class _VKULogoAnimationState extends State<VKULogoAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating grid pattern background
              Transform.rotate(
                angle: _rotationAnimation.value,
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: GridPatternPainter(
                    progress: _controller.value,
                  ),
                ),
              ),
              // VKU logo (simplified representation)
              Opacity(
                opacity: _pulseAnimation.value,
                child: Container(
                  width: widget.size * 0.6,
                  height: widget.size * 0.6,
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradientRedToNavy,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.vkuRed.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'VKU',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Custom painter for animated grid pattern
class GridPatternPainter extends CustomPainter {
  final double progress;

  GridPatternPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw morphing grid lines
    for (var i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3) + (progress * math.pi * 2);
      final radius = size.width / 2;
      
      // Gradient color based on angle
      final colorProgress = (i / 6);
      paint.color = Color.lerp(
        AppTheme.vkuRed,
        AppTheme.vkuYellow,
        colorProgress,
      )!.withValues(alpha: 0.3);

      final x1 = centerX + math.cos(angle) * radius * 0.3;
      final y1 = centerY + math.sin(angle) * radius * 0.3;
      final x2 = centerX + math.cos(angle) * radius;
      final y2 = centerY + math.sin(angle) * radius;

      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPatternPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Gradient progress bar with VKU colors (red → yellow → navy)
class VKUGradientProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final double borderRadius;

  const VKUGradientProgressBar({
    super.key,
    required this.progress,
    this.height = 8.0,
    this.borderRadius = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.dividerColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            // Animated gradient fill
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: const [
                      AppTheme.vkuRed,
                      AppTheme.vkuYellow,
                      AppTheme.vkuNavy,
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Shimmer effect
            AnimatedShimmer(
              progress: progress,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer effect for progress bar
class AnimatedShimmer extends StatefulWidget {
  final double progress;

  const AnimatedShimmer({
    super.key,
    required this.progress,
  });

  @override
  State<AnimatedShimmer> createState() => _AnimatedShimmerState();
}

class _AnimatedShimmerState extends State<AnimatedShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
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
        return FractionallySizedBox(
          widthFactor: widget.progress.clamp(0.0, 1.0),
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white.withValues(alpha: 0.0),
                  Colors.white.withValues(alpha: 0.3),
                  Colors.white.withValues(alpha: 0.0),
                ],
                stops: [
                  (_controller.value - 0.3).clamp(0.0, 1.0),
                  _controller.value,
                  (_controller.value + 0.3).clamp(0.0, 1.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Animated progress steps with checkmarks
class ProgressSteps extends StatelessWidget {
  final int currentStep; // 0-based index
  final List<String> steps;

  const ProgressSteps({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (index) {
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              // Step indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppTheme.vkuYellow
                      : isCurrent
                          ? AppTheme.vkuRed
                          : AppTheme.dividerColor,
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: AppTheme.vkuRed.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.check,
                        color: AppTheme.textDark,
                        size: 20,
                      )
                    : Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isCurrent
                                ? Colors.white
                                : AppTheme.textLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              // Step label
              Expanded(
                child: Text(
                  steps[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                    color: isCompleted || isCurrent
                        ? AppTheme.textDark
                        : AppTheme.textLight,
                  ),
                ),
              ),
              // Loading indicator for current step
              if (isCurrent)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.vkuRed),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

/// Particle effects with VKU colors
class ParticleEffect extends StatefulWidget {
  final int particleCount;
  final double size;

  const ParticleEffect({
    super.key,
    this.particleCount = 30,
    this.size = 300.0,
  });

  @override
  State<ParticleEffect> createState() => _ParticleEffectState();
}

class _ParticleEffectState extends State<ParticleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    _particles = List.generate(
      widget.particleCount,
      (index) => Particle(
        color: _getVKUColor(index),
        size: math.Random().nextDouble() * 4 + 2,
        startX: math.Random().nextDouble(),
        startY: math.Random().nextDouble(),
        speedX: (math.Random().nextDouble() - 0.5) * 0.5,
        speedY: (math.Random().nextDouble() - 0.5) * 0.5,
      ),
    );
  }

  Color _getVKUColor(int index) {
    final colors = [
      AppTheme.vkuRed,
      AppTheme.vkuYellow,
      AppTheme.vkuNavy,
    ];
    return colors[index % colors.length].withValues(alpha: 0.6);
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
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: ParticlePainter(
            particles: _particles,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class Particle {
  final Color color;
  final double size;
  final double startX;
  final double startY;
  final double speedX;
  final double speedY;

  Particle({
    required this.color,
    required this.size,
    required this.startX,
    required this.startY,
    required this.speedX,
    required this.speedY,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final x = (particle.startX + particle.speedX * progress) % 1.0;
      final y = (particle.startY + particle.speedY * progress) % 1.0;

      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Countdown timer animation
class CountdownTimer extends StatefulWidget {
  final int totalSeconds;
  final VoidCallback? onComplete;

  const CountdownTimer({
    super.key,
    required this.totalSeconds,
    this.onComplete,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.totalSeconds;
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        _startCountdown();
      } else if (mounted && _remainingSeconds == 0) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (value * 0.1),
          child: Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.vkuNavy,
                  fontFeatures: const [
                    FontFeature.tabularFigures(),
                  ],
                ),
          ),
        );
      },
    );
  }
}
