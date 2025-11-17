import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum VKUGradientType {
  redToYellow,
  yellowToNavy,
  redToNavy,
  navyToRed,
  redSubtle,
  yellowSubtle,
  navySubtle,
}

class VKUGradientContainer extends StatelessWidget {
  final Widget child;
  final VKUGradientType gradientType;
  final double? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final AlignmentGeometry? begin;
  final AlignmentGeometry? end;
  final List<BoxShadow>? shadows;

  const VKUGradientContainer({
    super.key,
    required this.child,
    this.gradientType = VKUGradientType.redToYellow,
    this.borderRadius,
    this.padding,
    this.margin,
    this.begin,
    this.end,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        gradient: _getGradient(),
        borderRadius: borderRadius != null
            ? BorderRadius.circular(borderRadius!)
            : null,
        boxShadow: shadows,
      ),
      child: child,
    );
  }

  Gradient _getGradient() {
    final effectiveBegin = begin ?? Alignment.topLeft;
    final effectiveEnd = end ?? Alignment.bottomRight;

    switch (gradientType) {
      case VKUGradientType.redToYellow:
        return LinearGradient(
          colors: const [AppTheme.vkuRed, AppTheme.vkuYellow],
          begin: effectiveBegin,
          end: effectiveEnd,
        );
      case VKUGradientType.yellowToNavy:
        return LinearGradient(
          colors: const [AppTheme.vkuYellow, AppTheme.vkuNavy],
          begin: effectiveBegin,
          end: effectiveEnd,
        );
      case VKUGradientType.redToNavy:
        return LinearGradient(
          colors: const [AppTheme.vkuRed, AppTheme.vkuNavy],
          begin: effectiveBegin,
          end: effectiveEnd,
        );
      case VKUGradientType.navyToRed:
        return LinearGradient(
          colors: const [AppTheme.vkuNavy, AppTheme.vkuRed],
          begin: effectiveBegin,
          end: effectiveEnd,
        );
      case VKUGradientType.redSubtle:
        return LinearGradient(
          colors: const [AppTheme.vkuRed50, AppTheme.vkuRed100],
          begin: effectiveBegin,
          end: effectiveEnd,
        );
      case VKUGradientType.yellowSubtle:
        return LinearGradient(
          colors: const [AppTheme.vkuYellow50, AppTheme.vkuYellow100],
          begin: effectiveBegin,
          end: effectiveEnd,
        );
      case VKUGradientType.navySubtle:
        return LinearGradient(
          colors: const [AppTheme.vkuNavy50, AppTheme.vkuNavy100],
          begin: effectiveBegin,
          end: effectiveEnd,
        );
    }
  }
}
