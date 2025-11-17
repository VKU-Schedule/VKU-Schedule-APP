import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum VKUButtonVariant {
  primary, // Red
  secondary, // Yellow
  tertiary, // Navy
  outlined,
  text,
}

enum VKUButtonSize {
  small,
  medium,
  large,
}

class VKUButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final VKUButtonVariant variant;
  final VKUButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final bool useGradient;

  const VKUButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = VKUButtonVariant.primary,
    this.size = VKUButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.useGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = _buildButtonContent();
    
    if (variant == VKUButtonVariant.outlined) {
      return _buildOutlinedButton(buttonChild);
    } else if (variant == VKUButtonVariant.text) {
      return _buildTextButton(buttonChild);
    } else {
      return _buildFilledButton(buttonChild);
    }
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        height: _getIconSize(),
        width: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getForegroundColor(),
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: _getIconSize()),
          SizedBox(width: _getSpacing()),
          Text(text),
        ],
      );
    }

    return Text(text);
  }

  Widget _buildFilledButton(Widget child) {
    if (useGradient) {
      return Container(
        width: fullWidth ? double.infinity : null,
        height: _getHeight(),
        decoration: BoxDecoration(
          gradient: _getGradient(),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          boxShadow: AppTheme.subtleShadows,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: Center(
              child: Padding(
                padding: _getPadding(),
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontSize: _getFontSize(),
                    fontWeight: FontWeight.w500,
                    color: _getForegroundColor(),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getHeight(),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(),
          foregroundColor: _getForegroundColor(),
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          elevation: 2,
          textStyle: TextStyle(
            fontSize: _getFontSize(),
            fontWeight: FontWeight.w500,
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildOutlinedButton(Widget child) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getHeight(),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _getBackgroundColor(),
          side: BorderSide(color: _getBackgroundColor(), width: 1.5),
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          textStyle: TextStyle(
            fontSize: _getFontSize(),
            fontWeight: FontWeight.w500,
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildTextButton(Widget child) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getHeight(),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: _getBackgroundColor(),
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          textStyle: TextStyle(
            fontSize: _getFontSize(),
            fontWeight: FontWeight.w500,
          ),
        ),
        child: child,
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (variant) {
      case VKUButtonVariant.primary:
        return AppTheme.vkuRed;
      case VKUButtonVariant.secondary:
        return AppTheme.vkuYellow;
      case VKUButtonVariant.tertiary:
        return AppTheme.vkuNavy;
      default:
        return AppTheme.vkuRed;
    }
  }

  Color _getForegroundColor() {
    switch (variant) {
      case VKUButtonVariant.primary:
      case VKUButtonVariant.tertiary:
        return Colors.white;
      case VKUButtonVariant.secondary:
        return AppTheme.textDark;
      default:
        return Colors.white;
    }
  }

  Gradient _getGradient() {
    switch (variant) {
      case VKUButtonVariant.primary:
        return const LinearGradient(
          colors: [AppTheme.vkuRed, AppTheme.vkuRed700],
        );
      case VKUButtonVariant.secondary:
        return AppTheme.gradientRedToYellow;
      case VKUButtonVariant.tertiary:
        return const LinearGradient(
          colors: [AppTheme.vkuNavy, AppTheme.vkuNavy700],
        );
      default:
        return AppTheme.gradientRedToYellow;
    }
  }

  double _getHeight() {
    switch (size) {
      case VKUButtonSize.small:
        return 36;
      case VKUButtonSize.medium:
        return 48;
      case VKUButtonSize.large:
        return 56;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case VKUButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case VKUButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case VKUButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double _getFontSize() {
    switch (size) {
      case VKUButtonSize.small:
        return 12;
      case VKUButtonSize.medium:
        return 14;
      case VKUButtonSize.large:
        return 16;
    }
  }

  double _getIconSize() {
    switch (size) {
      case VKUButtonSize.small:
        return 16;
      case VKUButtonSize.medium:
        return 20;
      case VKUButtonSize.large:
        return 24;
    }
  }

  double _getSpacing() {
    switch (size) {
      case VKUButtonSize.small:
        return 4;
      case VKUButtonSize.medium:
        return 8;
      case VKUButtonSize.large:
        return 12;
    }
  }
}
