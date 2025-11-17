import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/session.dart';
import '../theme/app_theme.dart';

class SessionCard extends StatefulWidget {
  final Session session;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isEditing;
  final bool hasConflict;
  final int periodCount;

  const SessionCard({
    super.key,
    required this.session,
    this.onTap,
    this.onLongPress,
    this.isEditing = false,
    this.hasConflict = false,
    required this.periodCount,
  });

  @override
  State<SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<SessionCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 60),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _getMaxLines() {
    // Tính số dòng tối đa dựa trên số tiết
    // Mỗi tiết cao 60px, trừ padding và details
    if (widget.periodCount == 1) return 2;
    if (widget.periodCount == 2) return 4;
    if (widget.periodCount == 3) return 6;
    return 8; // 4+ tiết
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _getAccentColor();
    final gradient = _getGradient();
    
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) {
          _controller.forward();
          HapticFeedback.lightImpact();
        },
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.onTap,
        onLongPress: widget.isEditing ? () {
          HapticFeedback.mediumImpact();
          widget.onLongPress?.call();
        } : null,
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.hasConflict
                  ? AppTheme.vkuRed
                  : accentColor.withValues(alpha: 0.3),
              width: widget.hasConflict ? 2 : 1.5,
            ),
            boxShadow: widget.hasConflict
                ? [
                    BoxShadow(
                      color: AppTheme.vkuRed.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Glassmorphism
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.3),
                        Colors.white.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course name only
                      Text(
                        widget.session.courseName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                          height: 1.3,
                          letterSpacing: 0.1,
                        ),
                        maxLines: _getMaxLines(),
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                    ],
                  ),
                ),
                // Conflict indicator
                if (widget.hasConflict)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.vkuRed,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.vkuRed.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.warning_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                // Edit border
                if (widget.isEditing)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.vkuRed, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  LinearGradient _getGradient() {
    final hash = widget.session.subjectId.hashCode.abs();
    const gradients = [
      LinearGradient(
        colors: [AppTheme.vkuRed50, AppTheme.vkuRed100],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [AppTheme.vkuYellow50, AppTheme.vkuYellow100],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [AppTheme.vkuNavy50, AppTheme.vkuNavy100],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [AppTheme.subjectOrange, AppTheme.warningLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [AppTheme.subjectPurple, Color(0xFFE1BEE7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [AppTheme.subjectPink, Color(0xFFF8BBD0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ];
    return gradients[hash % gradients.length];
  }

  Color _getAccentColor() {
    final hash = widget.session.subjectId.hashCode.abs();
    const colors = [
      AppTheme.vkuRed,
      AppTheme.vkuYellow800,
      AppTheme.vkuNavy,
      AppTheme.warning,
      Color(0xFF7B1FA2),
      Color(0xFFC2185B),
    ];
    return colors[hash % colors.length];
  }


}
