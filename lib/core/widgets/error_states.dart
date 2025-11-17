import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Error type enum for different error scenarios
enum ErrorType {
  network,
  timeout,
  server,
  validation,
  unknown,
}

/// Beautiful error state widget with VKU branding
class VKUErrorState extends StatelessWidget {
  final ErrorType errorType;
  final String? customMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onSupport;
  final bool showOfflineIndicator;

  const VKUErrorState({
    super.key,
    required this.errorType,
    this.customMessage,
    this.onRetry,
    this.onSupport,
    this.showOfflineIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    final errorInfo = _getErrorInfo();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Offline indicator
            if (showOfflineIndicator) ...[
              const OfflineIndicator(),
              const SizedBox(height: AppTheme.spaceLg),
            ],

            // Error illustration
            ErrorIllustration(
              icon: errorInfo.icon,
              color: errorInfo.color,
            ),

            const SizedBox(height: AppTheme.spaceLg),

            // Error title
            Text(
              errorInfo.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: errorInfo.color,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppTheme.spaceMd),

            // Error message
            Text(
              customMessage ?? errorInfo.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textMedium,
                    height: 1.6,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppTheme.spaceLg),

            // Suggestion
            if (errorInfo.suggestion != null)
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                decoration: BoxDecoration(
                  color: errorInfo.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(
                    color: errorInfo.color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: errorInfo.color,
                      size: 20,
                    ),
                    const SizedBox(width: AppTheme.spaceSm),
                    Expanded(
                      child: Text(
                        errorInfo.suggestion!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textDark,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppTheme.spaceLg),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onRetry != null)
                  Expanded(
                    child: AnimatedRetryButton(
                      onPressed: onRetry!,
                      color: errorInfo.color,
                    ),
                  ),
                if (onRetry != null && onSupport != null)
                  const SizedBox(width: AppTheme.spaceMd),
                if (onSupport != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onSupport,
                      icon: const Icon(Icons.support_agent),
                      label: const Text('Hỗ trợ'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.vkuNavy,
                        side: const BorderSide(
                          color: AppTheme.vkuNavy,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spaceLg,
                          vertical: AppTheme.spaceMd,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ErrorInfo _getErrorInfo() {
    switch (errorType) {
      case ErrorType.network:
        return ErrorInfo(
          icon: Icons.wifi_off,
          color: AppTheme.vkuRed,
          title: 'Không có kết nối',
          message: 'Vui lòng kiểm tra kết nối internet của bạn và thử lại.',
          suggestion: 'Bật Wi-Fi hoặc dữ liệu di động để tiếp tục',
        );
      case ErrorType.timeout:
        return ErrorInfo(
          icon: Icons.access_time,
          color: AppTheme.warning,
          title: 'Hết thời gian chờ',
          message: 'Yêu cầu mất quá nhiều thời gian. Vui lòng thử lại.',
          suggestion: 'Quá trình tối ưu có thể mất 30-60 giây',
        );
      case ErrorType.server:
        return ErrorInfo(
          icon: Icons.cloud_off,
          color: AppTheme.vkuRed,
          title: 'Lỗi máy chủ',
          message: 'Máy chủ đang gặp sự cố. Vui lòng thử lại sau.',
          suggestion: 'Chúng tôi đang khắc phục sự cố này',
        );
      case ErrorType.validation:
        return ErrorInfo(
          icon: Icons.error_outline,
          color: AppTheme.warning,
          title: 'Dữ liệu không hợp lệ',
          message: 'Vui lòng kiểm tra lại thông tin đã nhập.',
          suggestion: 'Đảm bảo bạn đã chọn ít nhất một môn học',
        );
      case ErrorType.unknown:
        return ErrorInfo(
          icon: Icons.help_outline,
          color: AppTheme.vkuNavy,
          title: 'Đã xảy ra lỗi',
          message: 'Đã có lỗi không xác định xảy ra. Vui lòng thử lại.',
          suggestion: null,
        );
    }
  }
}

class ErrorInfo {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String? suggestion;

  ErrorInfo({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    this.suggestion,
  });
}

/// Error illustration with animation
class ErrorIllustration extends StatefulWidget {
  final IconData icon;
  final Color color;

  const ErrorIllustration({
    super.key,
    required this.icon,
    required this.color,
  });

  @override
  State<ErrorIllustration> createState() => _ErrorIllustrationState();
}

class _ErrorIllustrationState extends State<ErrorIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
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
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    widget.color.withValues(alpha: 0.1),
                    widget.color.withValues(alpha: 0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                size: 64,
                color: widget.color,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Animated retry button with gradient
class AnimatedRetryButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color color;

  const AnimatedRetryButton({
    super.key,
    required this.onPressed,
    required this.color,
  });

  @override
  State<AnimatedRetryButton> createState() => _AnimatedRetryButtonState();
}

class _AnimatedRetryButtonState extends State<AnimatedRetryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

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
        return GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onPressed();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform: Matrix4.identity()
              ..scale(_isPressed ? 0.95 : 1.0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceLg,
                vertical: AppTheme.spaceMd,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.color,
                    AppTheme.lighten(widget.color, 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.rotate(
                    angle: _controller.value * 2 * 3.14159,
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceSm),
                  const Text(
                    'Thử lại',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Offline mode indicator with icon animation
class OfflineIndicator extends StatefulWidget {
  const OfflineIndicator({super.key});

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

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
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceMd,
              vertical: AppTheme.spaceSm,
            ),
            decoration: BoxDecoration(
              color: AppTheme.vkuRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(
                color: AppTheme.vkuRed.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off,
                  color: AppTheme.vkuRed,
                  size: 16,
                ),
                const SizedBox(width: AppTheme.spaceSm),
                Text(
                  'Chế độ ngoại tuyến',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.vkuRed,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Helper function to determine error type from exception
ErrorType getErrorTypeFromException(Object error) {
  final errorString = error.toString().toLowerCase();
  
  if (errorString.contains('socket') ||
      errorString.contains('network') ||
      errorString.contains('connection')) {
    return ErrorType.network;
  } else if (errorString.contains('timeout')) {
    return ErrorType.timeout;
  } else if (errorString.contains('server') ||
      errorString.contains('500') ||
      errorString.contains('503')) {
    return ErrorType.server;
  } else if (errorString.contains('validation') ||
      errorString.contains('invalid')) {
    return ErrorType.validation;
  } else {
    return ErrorType.unknown;
  }
}
