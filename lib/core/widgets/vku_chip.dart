import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum VKUChipVariant {
  red,
  yellow,
  navy,
  neutral,
}

class VKUChip extends StatelessWidget {
  final String label;
  final VKUChipVariant variant;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool useGradient;
  final bool selected;

  const VKUChip({
    super.key,
    required this.label,
    this.variant = VKUChipVariant.neutral,
    this.icon,
    this.onTap,
    this.onDelete,
    this.useGradient = false,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    if (useGradient) {
      return _buildGradientChip();
    }

    return Chip(
      label: Text(label),
      avatar: icon != null ? Icon(icon, size: 16) : null,
      deleteIcon: onDelete != null ? const Icon(Icons.close, size: 18) : null,
      onDeleted: onDelete,
      backgroundColor: selected ? _getSelectedColor() : _getBackgroundColor(),
      labelStyle: TextStyle(
        color: _getTextColor(),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        side: selected
            ? BorderSide(color: _getBorderColor(), width: 1.5)
            : BorderSide.none,
      ),
    );
  }

  Widget _buildGradientChip() {
    return Container(
      decoration: BoxDecoration(
        gradient: _getGradient(),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: _getGradientTextColor()),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: _getGradientTextColor(),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (onDelete != null) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: _getGradientTextColor(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (variant) {
      case VKUChipVariant.red:
        return AppTheme.vkuRed50;
      case VKUChipVariant.yellow:
        return AppTheme.vkuYellow50;
      case VKUChipVariant.navy:
        return AppTheme.vkuNavy50;
      case VKUChipVariant.neutral:
        return AppTheme.backgroundGrey;
    }
  }

  Color _getSelectedColor() {
    switch (variant) {
      case VKUChipVariant.red:
        return AppTheme.vkuRed100;
      case VKUChipVariant.yellow:
        return AppTheme.vkuYellow100;
      case VKUChipVariant.navy:
        return AppTheme.vkuNavy100;
      case VKUChipVariant.neutral:
        return AppTheme.dividerColor;
    }
  }

  Color _getTextColor() {
    switch (variant) {
      case VKUChipVariant.red:
        return AppTheme.vkuRed700;
      case VKUChipVariant.yellow:
        return AppTheme.vkuYellow900;
      case VKUChipVariant.navy:
        return AppTheme.vkuNavy700;
      case VKUChipVariant.neutral:
        return AppTheme.textDark;
    }
  }

  Color _getBorderColor() {
    switch (variant) {
      case VKUChipVariant.red:
        return AppTheme.vkuRed;
      case VKUChipVariant.yellow:
        return AppTheme.vkuYellow700;
      case VKUChipVariant.navy:
        return AppTheme.vkuNavy;
      case VKUChipVariant.neutral:
        return AppTheme.textLight;
    }
  }

  Gradient _getGradient() {
    switch (variant) {
      case VKUChipVariant.red:
        return const LinearGradient(
          colors: [AppTheme.vkuRed, AppTheme.vkuRed700],
        );
      case VKUChipVariant.yellow:
        return AppTheme.gradientRedToYellow;
      case VKUChipVariant.navy:
        return const LinearGradient(
          colors: [AppTheme.vkuNavy, AppTheme.vkuNavy700],
        );
      case VKUChipVariant.neutral:
        return const LinearGradient(
          colors: [AppTheme.backgroundGrey, AppTheme.dividerColor],
        );
    }
  }

  Color _getGradientTextColor() {
    return variant == VKUChipVariant.yellow ? AppTheme.textDark : Colors.white;
  }
}
