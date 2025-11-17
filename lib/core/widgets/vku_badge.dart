import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum VKUBadgeVariant {
  red,
  yellow,
  navy,
  success,
  warning,
  error,
  info,
}

class VKUBadge extends StatefulWidget {
  final String text;
  final VKUBadgeVariant variant;
  final bool animated;
  final IconData? icon;
  final double? size;

  const VKUBadge({
    super.key,
    required this.text,
    this.variant = VKUBadgeVariant.red,
    this.animated = false,
    this.icon,
    this.size,
  });

  @override
  State<VKUBadge> createState() => _VKUBadgeState();
}

class _VKUBadgeState extends State<VKUBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.animated) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      )..repeat(reverse: true);

      _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    if (widget.animated) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.size ?? 8,
        vertical: (widget.size ?? 8) * 0.5,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        boxShadow: [
          BoxShadow(
            color: _getBackgroundColor().withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Icon(
              widget.icon,
              size: (widget.size ?? 8) * 1.5,
              color: _getTextColor(),
            ),
            SizedBox(width: (widget.size ?? 8) * 0.5),
          ],
          Text(
            widget.text,
            style: TextStyle(
              color: _getTextColor(),
              fontSize: (widget.size ?? 8) * 1.25,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );

    if (widget.animated) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: badge,
      );
    }

    return badge;
  }

  Color _getBackgroundColor() {
    switch (widget.variant) {
      case VKUBadgeVariant.red:
        return AppTheme.vkuRed;
      case VKUBadgeVariant.yellow:
        return AppTheme.vkuYellow;
      case VKUBadgeVariant.navy:
        return AppTheme.vkuNavy;
      case VKUBadgeVariant.success:
        return AppTheme.success;
      case VKUBadgeVariant.warning:
        return AppTheme.warning;
      case VKUBadgeVariant.error:
        return AppTheme.error;
      case VKUBadgeVariant.info:
        return AppTheme.info;
    }
  }

  Color _getTextColor() {
    switch (widget.variant) {
      case VKUBadgeVariant.yellow:
        return AppTheme.textDark;
      default:
        return Colors.white;
    }
  }
}
