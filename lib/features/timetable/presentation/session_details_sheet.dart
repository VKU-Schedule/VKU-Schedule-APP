import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/session.dart';
import '../../../core/theme/app_theme.dart';

class SessionDetailsSheet extends StatefulWidget {
  final Session session;
  final List<Session> relatedSessions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final VoidCallback? onAddToCalendar;

  const SessionDetailsSheet({
    super.key,
    required this.session,
    this.relatedSessions = const [],
    this.onEdit,
    this.onDelete,
    this.onShare,
    this.onAddToCalendar,
  });

  @override
  State<SessionDetailsSheet> createState() => _SessionDetailsSheetState();
}

class _SessionDetailsSheetState extends State<SessionDetailsSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! > 300) {
          _handleDismiss();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _getAccentColor().withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                _buildDragHandle(),
                // Hero header
                _buildHeroHeader(),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoSection(),
                        const SizedBox(height: 20),
                        _buildQuickActionsBar(),
                        if (widget.relatedSessions.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildRelatedSessionsSection(),
                        ],
                      ],
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

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getAccentColor(),
            _getAccentColor().withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _getAccentColor().withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getSubjectIcon(),
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.session.courseName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.session.subTopic,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      decoration: AppTheme.glassmorphism(
        borderRadius: 16,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin chi tiết',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _getAccentColor(),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.schedule_outlined,
            'Thời gian',
            '${widget.session.dayName}, ${widget.session.periodRange}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.location_on_outlined,
            'Phòng học',
            '${widget.session.room} - ${widget.session.area}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.person_outline,
            'Giảng viên',
            widget.session.teacher,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.group_outlined,
            'Nhóm lớp',
            widget.session.group,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.people_outline,
            'Sĩ số',
            '${widget.session.classSize} sinh viên',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.language_outlined,
            'Ngôn ngữ',
            widget.session.language,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getAccentColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: _getAccentColor(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsBar() {
    return Container(
      decoration: AppTheme.glassmorphism(
        borderRadius: 16,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thao tác nhanh',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _getAccentColor(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (widget.onEdit != null)
                _buildActionButton(
                  icon: Icons.edit_outlined,
                  label: 'Sửa',
                  color: AppTheme.vkuNavy,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    widget.onEdit?.call();
                  },
                ),
              if (widget.onDelete != null)
                _buildActionButton(
                  icon: Icons.delete_outline,
                  label: 'Xóa',
                  color: AppTheme.vkuRed,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    widget.onDelete?.call();
                  },
                ),
              if (widget.onShare != null)
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: 'Chia sẻ',
                  color: AppTheme.vkuYellow800,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onShare?.call();
                  },
                ),
              if (widget.onAddToCalendar != null)
                _buildActionButton(
                  icon: Icons.calendar_today_outlined,
                  label: 'Lịch',
                  color: AppTheme.success,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onAddToCalendar?.call();
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedSessionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Các buổi học liên quan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _getAccentColor(),
          ),
        ),
        const SizedBox(height: 12),
        ...widget.relatedSessions.map((session) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.dividerColor,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 20,
                  color: _getAccentColor(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.courseName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${session.dayName}, ${session.periodRange}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Color _getAccentColor() {
    final hash = widget.session.subjectId.hashCode;
    final colors = [
      AppTheme.vkuRed,
      AppTheme.vkuYellow800,
      AppTheme.vkuNavy,
      AppTheme.warning,
      const Color(0xFF7B1FA2),
      const Color(0xFFC2185B),
    ];
    return colors[hash.abs() % colors.length];
  }

  IconData _getSubjectIcon() {
    final courseName = widget.session.courseName.toLowerCase();
    if (courseName.contains('toán') || courseName.contains('math')) {
      return Icons.calculate_outlined;
    } else if (courseName.contains('lý') || courseName.contains('physics')) {
      return Icons.science_outlined;
    } else if (courseName.contains('hóa') || courseName.contains('chemistry')) {
      return Icons.biotech_outlined;
    } else if (courseName.contains('tin') ||
        courseName.contains('lập trình') ||
        courseName.contains('programming')) {
      return Icons.computer_outlined;
    } else if (courseName.contains('anh') || courseName.contains('english')) {
      return Icons.language_outlined;
    } else if (courseName.contains('văn') || courseName.contains('literature')) {
      return Icons.menu_book_outlined;
    } else if (courseName.contains('sử') || courseName.contains('history')) {
      return Icons.history_edu_outlined;
    } else if (courseName.contains('địa') || courseName.contains('geography')) {
      return Icons.public_outlined;
    } else if (courseName.contains('thể') || courseName.contains('physical')) {
      return Icons.sports_outlined;
    } else {
      return Icons.school_outlined;
    }
  }
}

/// Helper function to show session details sheet
Future<void> showSessionDetails(
  BuildContext context,
  Session session, {
  List<Session> relatedSessions = const [],
  VoidCallback? onEdit,
  VoidCallback? onDelete,
  VoidCallback? onShare,
  VoidCallback? onAddToCalendar,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => SessionDetailsSheet(
        session: session,
        relatedSessions: relatedSessions,
        onEdit: onEdit,
        onDelete: onDelete,
        onShare: onShare,
        onAddToCalendar: onAddToCalendar,
      ),
    ),
  );
}
