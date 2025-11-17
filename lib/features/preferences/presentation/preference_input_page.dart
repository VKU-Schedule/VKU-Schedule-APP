import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/vku_components.dart';
import '../providers/preferences_provider.dart';

class PreferenceInputPage extends ConsumerStatefulWidget {
  const PreferenceInputPage({super.key});

  @override
  ConsumerState<PreferenceInputPage> createState() =>
      _PreferenceInputPageState();
}

class _PreferenceInputPageState extends ConsumerState<PreferenceInputPage>
    with SingleTickerProviderStateMixin {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  bool _isFocused = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static const int maxCharacters = 500;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _textController.addListener(_onTextChange);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onTextChange() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  Future<void> _handleSubmit() async {
    final promptText = _textController.text.trim();
    
    if (promptText.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập sở thích của bạn';
      });
      return;
    }

    if (promptText.length < 10) {
      setState(() {
        _errorMessage = 'Vui lòng nhập ít nhất 10 ký tự';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    ref.read(preferencesProvider.notifier).updatePromptText(promptText);

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu sở thích'),
          backgroundColor: AppTheme.success,
        ),
      );

      context.go('/weights');
    }
  }

  void _insertTemplate(String template) {
    final currentText = _textController.text;
    final newText = currentText.isEmpty ? template : '$currentText, $template';
    
    setState(() {
      _textController.text = newText;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: newText.length),
      );
    });
    
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final characterCount = _textController.text.length;
    final isOverLimit = characterCount > maxCharacters;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhập sở thích'),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Mô tả sở thích của bạn',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppTheme.spaceSm),
                Text(
                  'Nhập bằng tiếng Việt tự nhiên hoặc chọn mẫu có sẵn',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textLight,
                      ),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                _buildQuickTemplates(),
                const SizedBox(height: AppTheme.spaceMd),
                _buildModernTextInput(),
                const SizedBox(height: AppTheme.spaceMd),
                _buildCharacterCounter(characterCount, isOverLimit),
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppTheme.spaceSm),
                  _buildErrorMessage(),
                ],
                const SizedBox(height: AppTheme.spaceLg),
                VKUButton(
                  text: 'Phân tích và tiếp tục',
                  onPressed: (_isLoading || isOverLimit) ? null : _handleSubmit,
                  isLoading: _isLoading,
                  fullWidth: true,
                  useGradient: true,
                  variant: VKUButtonVariant.primary,
                  size: VKUButtonSize.large,
                  icon: Icons.arrow_forward,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTemplates() {
    final templates = [
      _TemplateItem(
        icon: Icons.wb_sunny_outlined,
        label: 'Học buổi sáng',
        text: 'tôi thích học buổi sáng',
        variant: VKUChipVariant.yellow,
      ),
      _TemplateItem(
        icon: Icons.nights_stay_outlined,
        label: 'Học buổi chiều',
        text: 'tôi thích học buổi chiều',
        variant: VKUChipVariant.navy,
      ),
      _TemplateItem(
        icon: Icons.weekend_outlined,
        label: 'Không học cuối tuần',
        text: 'không học thứ bảy và chủ nhật',
        variant: VKUChipVariant.red,
      ),
      _TemplateItem(
        icon: Icons.calendar_today_outlined,
        label: 'Tập trung trong tuần',
        text: 'tôi muốn học tập trung từ thứ hai đến thứ sáu',
        variant: VKUChipVariant.yellow,
      ),
      _TemplateItem(
        icon: Icons.schedule_outlined,
        label: 'Không khoảng trống',
        text: 'tránh khoảng trống giữa các tiết học',
        variant: VKUChipVariant.navy,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.lightbulb_outline,
              size: 18,
              color: AppTheme.vkuYellow800,
            ),
            const SizedBox(width: AppTheme.spaceXs),
            Text(
              'Mẫu gợi ý',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.textMedium,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceSm),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: templates.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppTheme.spaceSm),
            itemBuilder: (context, index) {
              final template = templates[index];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 50)),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: VKUChip(
                  label: template.label,
                  icon: template.icon,
                  variant: template.variant,
                  useGradient: true,
                  onTap: () => _insertTemplate(template.text),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextInput() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: _errorMessage != null
              ? AppTheme.error
              : _isFocused
                  ? AppTheme.vkuRed
                  : AppTheme.dividerColor,
          width: _isFocused ? 2 : 1,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppTheme.vkuRed.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : AppTheme.subtleShadows,
      ),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: _buildAnimatedPlaceholder(),
          hintStyle: TextStyle(
            color: AppTheme.textLight.withValues(alpha: 0.6),
            fontSize: 15,
            height: 1.6,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.all(AppTheme.spaceMd),
        ),
        minLines: 8,
        maxLines: 12,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(
          fontSize: 15,
          height: 1.6,
          color: AppTheme.textDark,
        ),
      ),
    );
  }

  String _buildAnimatedPlaceholder() {
    return 'Ví dụ: Tôi thích học buổi sáng, không học thứ sáu, tránh các giảng viên Nguyễn Văn A...';
  }

  Widget _buildCharacterCounter(int count, bool isOverLimit) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceSm,
        vertical: AppTheme.spaceXs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isOverLimit
                  ? AppTheme.error
                  : count > maxCharacters * 0.9
                      ? AppTheme.warning
                      : count > maxCharacters * 0.7
                          ? AppTheme.vkuYellow800
                          : AppTheme.textLight,
            ),
            child: Text('$count / $maxCharacters'),
          ),
          if (isOverLimit) ...[
            const SizedBox(width: AppTheme.spaceXs),
            const Icon(
              Icons.error_outline,
              size: 16,
              color: AppTheme.error,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceMd,
                vertical: AppTheme.spaceSm,
              ),
              decoration: BoxDecoration(
                color: AppTheme.errorLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(
                  color: AppTheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 18,
                    color: AppTheme.error,
                  ),
                  const SizedBox(width: AppTheme.spaceSm),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.errorDark,
                        fontWeight: FontWeight.w500,
                      ),
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

class _TemplateItem {
  final IconData icon;
  final String label;
  final String text;
  final VKUChipVariant variant;

  const _TemplateItem({
    required this.icon,
    required this.label,
    required this.text,
    required this.variant,
  });
}


