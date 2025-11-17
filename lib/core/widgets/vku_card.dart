import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class VKUCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final bool useGlassmorphism;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadows;
  final Gradient? gradient;

  const VKUCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.useGlassmorphism = false,
    this.backgroundColor,
    this.onTap,
    this.shadows,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? AppTheme.radiusMd;
    
    Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(AppTheme.spaceMd),
      margin: margin,
      decoration: _getDecoration(effectiveBorderRadius),
      child: child,
    );

    if (onTap != null) {
      cardContent = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppTheme.spaceMd),
            child: child,
          ),
        ),
      );
      
      cardContent = Container(
        margin: margin,
        decoration: _getDecoration(effectiveBorderRadius),
        child: cardContent,
      );
    }

    return cardContent;
  }

  BoxDecoration _getDecoration(double radius) {
    if (gradient != null) {
      return BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadows ?? AppTheme.subtleShadows,
      );
    }

    if (useGlassmorphism) {
      return AppTheme.glassmorphism(
        color: backgroundColor,
        borderRadius: radius,
      );
    }

    return BoxDecoration(
      color: backgroundColor ?? AppTheme.backgroundWhite,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: shadows ?? AppTheme.subtleShadows,
    );
  }
}
