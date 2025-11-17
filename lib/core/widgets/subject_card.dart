import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/subject.dart';
import '../theme/app_theme.dart';

class SubjectCard extends StatefulWidget {
  final Subject subject;
  final int index;
  final bool isEnrolled;
  final bool isSkipped;
  final VoidCallback onEnroll;
  final VoidCallback onSkip;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.index,
    required this.isEnrolled,
    required this.isSkipped,
    required this.onEnroll,
    required this.onSkip,
  });

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _handleEnroll() {
    HapticFeedback.mediumImpact();
    widget.onEnroll();
  }

  void _handleSkip() {
    HapticFeedback.lightImpact();
    widget.onSkip();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.subject.id),
      background: _buildSwipeBackground(isLeft: false),
      secondaryBackground: _buildSwipeBackground(isLeft: true),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right = enroll
          if (!widget.isEnrolled) {
            _handleEnroll();
          }
        } else {
          // Swipe left = skip
          if (!widget.isSkipped) {
            _handleSkip();
          }
        }
        return false; // Don't actually dismiss
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            width: 2,
            color: widget.isEnrolled
                ? AppTheme.vkuRed.withValues(alpha: 0.3)
                : widget.isSkipped
                    ? Colors.grey.withValues(alpha: 0.2)
                    : Colors.transparent,
          ),
          boxShadow: AppTheme.subtleShadows,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Index badge with VKU red background
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppTheme.gradientRedToYellow,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.vkuRed.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${widget.index}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.subject.courseName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.subject.subTopic,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.textLight,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      // Expand icon
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                  
                  // Expandable details
                  SizeTransition(
                    sizeFactor: _expandAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                        if (widget.subject.code != null)
                          _buildDetailRow(
                            Icons.code,
                            'Mã môn học',
                            widget.subject.code!,
                          ),
                        if (widget.subject.credits != null)
                          _buildDetailRow(
                            Icons.school,
                            'Số tín chỉ',
                            '${widget.subject.credits} tín chỉ',
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildSkipButton(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _buildEnrollButton(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({required bool isLeft}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: isLeft
            ? const LinearGradient(
                colors: [Colors.grey, Colors.grey],
              )
            : AppTheme.gradientRedToYellow,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(
        isLeft ? Icons.close : Icons.check,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.vkuRed,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkipButton() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: widget.isSkipped
            ? Colors.grey.shade300
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isSkipped
              ? Colors.grey.shade400
              : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isSkipped ? null : _handleSkip,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.close,
                  size: 18,
                  color: widget.isSkipped
                      ? Colors.grey.shade600
                      : AppTheme.textMedium,
                ),
                const SizedBox(width: 6),
                Text(
                  'Bỏ qua',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: widget.isSkipped
                        ? Colors.grey.shade600
                        : AppTheme.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnrollButton() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        gradient: widget.isEnrolled
            ? null
            : AppTheme.gradientRedToYellow,
        color: widget.isEnrolled ? Colors.grey.shade300 : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: widget.isEnrolled ? null : AppTheme.subtleShadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isEnrolled ? null : _handleEnroll,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.isEnrolled ? Icons.check_circle : Icons.add_circle,
                  size: 20,
                  color: widget.isEnrolled
                      ? Colors.grey.shade600
                      : Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.isEnrolled ? 'Đã chọn' : 'Chọn môn',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: widget.isEnrolled
                        ? Colors.grey.shade600
                        : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


