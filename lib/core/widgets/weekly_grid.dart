import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/session.dart';
import '../theme/app_theme.dart';
import 'session_card.dart';

class WeeklyGrid extends StatefulWidget {
  final List<Session> sessions;
  final Function(Session)? onSessionTap;
  final Function(Session)? onSessionLongPress;
  final DateTime? currentWeek;
  final bool isEditing;

  const WeeklyGrid({
    super.key,
    required this.sessions,
    this.onSessionTap,
    this.onSessionLongPress,
    this.currentWeek,
    this.isEditing = false,
  });

  @override
  State<WeeklyGrid> createState() => _WeeklyGridState();
}

class _WeeklyGridState extends State<WeeklyGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 60),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Get hour label for a period (Tiết)
  String _getHourForPeriod(int period) {
    if (period <= 5) {
      final hour = 6 + period;
      return '${hour}h30';
    } else {
      final hour = 7 + period;
      return '${hour}h';
    }
  }

  /// Get day labels with dates if currentWeek is provided
  List<Map<String, String>> _getDayLabels() {
    const dayNames = [
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7',
      'CN'
    ];

    if (widget.currentWeek == null) {
      return dayNames.map((name) => {'name': name, 'date': ''}).toList();
    }

    final weekday = widget.currentWeek!.weekday;
    final daysFromMonday = weekday == 7 ? 6 : weekday - 1;
    final weekStart =
        widget.currentWeek!.subtract(Duration(days: daysFromMonday));

    return List.generate(7, (index) {
      final date = weekStart.add(Duration(days: index));
      final isToday = DateTime.now().year == date.year &&
          DateTime.now().month == date.month &&
          DateTime.now().day == date.day;

      return {
        'name': dayNames[index],
        'date': DateFormat('dd/MM').format(date),
        'isToday': isToday.toString(),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final dayLabels = _getDayLabels();
    const allPeriods = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

    // Build session maps
    final Map<String, Session> sessionMap = {};
    final Map<String, int> sessionFirstPeriodMap = {};
    for (final session in widget.sessions) {
      if (session.periods.isEmpty) continue;
      final sortedPeriods = List<int>.from(session.periods)..sort();
      final firstPeriod = sortedPeriods.first;
      final key = '${session.dayIndex}_$firstPeriod';
      sessionFirstPeriodMap[key] = sortedPeriods.length;

      for (final period in session.periods) {
        final cellKey = '${session.dayIndex}_$period';
        sessionMap[cellKey] = session;
      }
    }

    const cellHeight = 60.0;
    const cellVerticalMargin = 1.0;
    const headerHeight = 70.0;

    // Build merged blocks
    final List<Map<String, dynamic>> mergedBlocks = [];
    for (final session in widget.sessions) {
      if (session.periods.isEmpty) continue;
      final sortedPeriods = List<int>.from(session.periods)..sort();
      final firstPeriod = sortedPeriods.first;
      final periodCount = sortedPeriods.length;

      final top =
          headerHeight + (firstPeriod - 1) * (cellHeight + cellVerticalMargin * 2) + 8;
      final height =
          periodCount * cellHeight + (periodCount - 1) * cellVerticalMargin * 2;

      mergedBlocks.add({
        'session': session,
        'dayIndex': session.dayIndex,
        'top': top,
        'height': height,
        'periodCount': periodCount,
      });
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth - 50;
          final cellWidth = availableWidth / 7;

          return Stack(
            children: [
              Column(
                children: [
                  // Modern gradient header
                  _buildModernHeader(context, dayLabels),
                  // Period rows
                  ...allPeriods.map((period) {
                    return _buildPeriodRow(
                      context,
                      period,
                      sessionMap,
                      sessionFirstPeriodMap,
                      cellHeight,
                    );
                  }),
                ],
              ),
              // Merged session blocks
              ...mergedBlocks.map((block) {
                return _buildSessionBlock(
                  context,
                  block,
                  cellWidth,
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildModernHeader(
      BuildContext context, List<Map<String, String>> dayLabels) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.gradientNavyToRed,
        boxShadow: AppTheme.mediumShadows,
      ),
      child: Row(
        children: [
          const SizedBox(width: 50),
          ...dayLabels.map((dayLabel) {
            final isToday = dayLabel['isToday'] == 'true';
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 1),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                decoration: BoxDecoration(
                  color: isToday
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dayLabel['name']!,
                      style: TextStyle(
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                        color: Colors.white,
                        fontSize: isToday ? 11 : 10,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (dayLabel['date']!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        dayLabel['date']!,
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPeriodRow(
    BuildContext context,
    int period,
    Map<String, Session> sessionMap,
    Map<String, int> sessionFirstPeriodMap,
    double cellHeight,
  ) {
    return Row(
      children: [
        // Time label with better typography
        SizedBox(
          width: 50,
          child: Container(
            margin: const EdgeInsets.only(right: 1),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.vkuNavy50,
                  AppTheme.vkuNavy100,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border.all(
                color: AppTheme.vkuNavy200,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'T$period',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.vkuNavy700,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  _getHourForPeriod(period),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.vkuNavy500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        // Day cells
        ...List.generate(7, (dayIndex) {
          final key = '${dayIndex}_$period';
          final session = sessionMap[key];
          final firstPeriodKey = '${dayIndex}_$period';
          final periodCount = sessionFirstPeriodMap[firstPeriodKey];
          final isFirstPeriod = periodCount != null;

          if (session != null && !isFirstPeriod) {
            return Expanded(
              child: Container(
                height: cellHeight,
                margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            );
          }

          return Expanded(
            child: Container(
              height: cellHeight,
              margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
              decoration: BoxDecoration(
                color: session == null
                    ? Colors.white
                    : Colors.grey.withValues(alpha: 0.05),
                border: Border.all(
                  color: session == null
                      ? AppTheme.dividerColor
                      : Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSessionBlock(
    BuildContext context,
    Map<String, dynamic> block,
    double cellWidth,
  ) {
    final session = block['session'] as Session;
    final dayIndex = block['dayIndex'] as int;
    final top = block['top'] as double;
    final height = block['height'] as double;
    final periodCount = block['periodCount'] as int;

    // Check for conflicts
    final hasConflict = _checkSessionConflict(session);

    return Positioned(
      left: 50 + dayIndex * cellWidth,
      top: top,
      width: cellWidth,
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
        child: SessionCard(
          session: session,
          periodCount: periodCount,
          isEditing: widget.isEditing,
          hasConflict: hasConflict,
          onTap: () => widget.onSessionTap?.call(session),
          onLongPress: () => widget.onSessionLongPress?.call(session),
        ),
      ),
    );
  }

  bool _checkSessionConflict(Session session) {
    return widget.sessions.any((other) =>
        other != session &&
        other.dayIndex == session.dayIndex &&
        other.periods.any((p) => session.periods.contains(p)));
  }
}
