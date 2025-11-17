import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class StatsCards extends StatelessWidget {
  final int enrolledSubjectsCount;
  final int savedSchedulesCount;

  const StatsCards({
    super.key,
    required this.enrolledSubjectsCount,
    required this.savedSchedulesCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.book_outlined,
              label: 'Môn đã chọn',
              value: enrolledSubjectsCount.toString(),
              gradient: const LinearGradient(
                colors: [AppTheme.vkuRed, AppTheme.vkuRed700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/subjects');
              },
            ),
          ),
          const SizedBox(width: AppTheme.spaceMd),
          Expanded(
            child: _StatCard(
              icon: Icons.calendar_today_outlined,
              label: 'Lịch đã lưu',
              value: savedSchedulesCount.toString(),
              gradient: const LinearGradient(
                colors: [AppTheme.vkuYellow, AppTheme.vkuYellow800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/saved-schedules');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final Gradient gradient;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<int> _counterAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    final targetValue = int.tryParse(widget.value) ?? 0;
    _counterAnimation = IntTween(begin: 0, end: targetValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(
                color: _isPressed
                    ? widget.gradient.colors.first.withValues(alpha: 0.5)
                    : widget.gradient.colors.first.withValues(alpha: 0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.gradient.colors.first.withValues(alpha: 0.15),
                  blurRadius: _isPressed ? 8 : 12,
                  offset: Offset(0, _isPressed ? 2 : 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              child: Stack(
                children: [
                  // Gradient overlay on tap
                  Positioned.fill(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      decoration: BoxDecoration(
                        gradient: _isPressed
                            ? widget.gradient.scale(0.15)
                            : widget.gradient.scale(0.05),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.spaceMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon with gradient
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: widget.gradient,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: widget.gradient.colors.first
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),

                        const Spacer(),

                        // Animated counter
                        AnimatedBuilder(
                          animation: _counterAnimation,
                          builder: (context, child) {
                            return Text(
                              _counterAnimation.value.toString(),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                                height: 1.0,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: AppTheme.spaceXs),

                        // Label
                        Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMedium.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
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

// Extension to scale gradient opacity
extension GradientScale on Gradient {
  Gradient scale(double factor) {
    if (this is LinearGradient) {
      final linear = this as LinearGradient;
      return LinearGradient(
        colors: linear.colors
            .map((c) => c.withValues(alpha: c.a * factor))
            .toList(),
        begin: linear.begin,
        end: linear.end,
      );
    }
    return this;
  }
}
