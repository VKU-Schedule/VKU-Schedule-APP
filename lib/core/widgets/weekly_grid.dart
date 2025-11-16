import 'package:flutter/material.dart';

import '../../models/session.dart';

class WeeklyGrid extends StatelessWidget {
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

  /// Get hour label for a period (Tiết)
  /// Tiết 1 = 7h30, Tiết 2 = 8h30, ..., Tiết 5 = 11h30, Tiết 6 = 13h00, Tiết 7 = 14h00, ...
  /// Mỗi tiết = 50 phút học + 10 phút nghỉ = 60 phút
  String _getHourForPeriod(int period) {
    if (period <= 5) {
      // Tiết 1-5: 7h30, 8h30, 9h30, 10h30, 11h30
      // Tiết 1 = 7h30, Tiết 2 = 8h30 (7h30 + 1h), ...
      final hour = 6 + period; // 7, 8, 9, 10, 11
      return '${hour}h30';
    } else {
      // Tiết 6 trở đi: 13h00, 14h00, 15h00, ...
      // Tiết 6 = 13h00 (buổi chiều bắt đầu), Tiết 7 = 14h00, ...
      final hour = 7 + period; // 13, 14, 15, 16, 17, 18, 19
      return '${hour}h';
    }
  }

  /// Get day labels with dates if currentWeek is provided
  List<String> _getDayLabels() {
    const dayNames = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];
    
    if (currentWeek == null) {
      return dayNames;
    }
    
    // Calculate start of week (Monday = day 1)
    // DateTime.weekday: Monday = 1, Sunday = 7
    final weekday = currentWeek!.weekday;
    final daysFromMonday = weekday == 7 ? 6 : weekday - 1; // Convert Sunday (7) to 6
    final weekStart = currentWeek!.subtract(Duration(days: daysFromMonday));
    
    return List.generate(7, (index) {
      final date = weekStart.add(Duration(days: index));
      return '${dayNames[index]}\n${date.day}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final dayLabels = _getDayLabels();
    // All periods from 1 to 12
    const allPeriods = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

    // Build a map of (dayIndex, period) -> Session
    // This helps us find which session occupies which cell
    final Map<String, Session> sessionMap = {};
    // Also build a map to find the first period of each session
    final Map<String, int> sessionFirstPeriodMap = {};
    for (final session in sessions) {
      if (session.periods.isEmpty) continue;
      final sortedPeriods = List<int>.from(session.periods)..sort();
      final firstPeriod = sortedPeriods.first;
      final key = '${session.dayIndex}_$firstPeriod';
      sessionFirstPeriodMap[key] = sortedPeriods.length; // Store period count
      
      for (final period in session.periods) {
        final cellKey = '${session.dayIndex}_$period';
        sessionMap[cellKey] = session;
      }
    }

    // Calculate positions for merged blocks
    final cellHeight = 55.0;
    final cellVerticalMargin = 0.5; // vertical margin (top + bottom = 1.0)
    // Header height: padding (10*2) + text (10*1.2*2 for 2 lines) + buffer = ~44
    // Actually measure: padding 20 + text ~24 (2 lines) = 44
    final headerHeight = 54.0;
    
    // Build list of merged blocks to position
    final List<Map<String, dynamic>> mergedBlocks = [];
    for (final session in sessions) {
      if (session.periods.isEmpty) continue;
      final sortedPeriods = List<int>.from(session.periods)..sort();
      final firstPeriod = sortedPeriods.first;
      final periodCount = sortedPeriods.length;
      
      // Calculate top position: header + (firstPeriod - 1) * (cellHeight + verticalMargin*2)
      // Each cell has margin top and bottom, so spacing between cells = margin*2
      final top = headerHeight + (firstPeriod - 1) * (cellHeight + cellVerticalMargin * 2);
      final height = periodCount * cellHeight + (periodCount - 1) * cellVerticalMargin * 2;
      
      mergedBlocks.add({
        'session': session,
        'dayIndex': session.dayIndex,
        'top': top,
        'height': height,
        'periodCount': periodCount,
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - 46; // Subtract period label width
        final cellWidth = availableWidth / 7;
        
        return Stack(
          children: [
            // Base grid (background cells)
            Column(
          children: [
            // Header row with improved styling
            Row(
              children: [
                const SizedBox(width: 46),
                ...dayLabels.map((dayLabel) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withOpacity(0.85),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          dayLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 10,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            // Period rows - each row is one period (background grid)
            ...allPeriods.map((period) {
              return Row(
                children: [
                  // Period label with hour
                  SizedBox(
                    width: 46,
                    child: Container(
                      margin: const EdgeInsets.only(right: 1),
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          _getHourForPeriod(period),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  // Day cells (background only)
                  ...List.generate(7, (dayIndex) {
                    final key = '${dayIndex}_$period';
                    final session = sessionMap[key];
                    
                    // Check if this is the first period of a merged session
                    final firstPeriodKey = '${dayIndex}_$period';
                    final periodCount = sessionFirstPeriodMap[firstPeriodKey];
                    final isFirstPeriod = periodCount != null;
                    
                    // Skip rendering content for non-first periods of merged sessions
                    if (session != null && !isFirstPeriod) {
                      return Expanded(
                        child: Container(
                          height: cellHeight,
                          margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 0.5),
                          decoration: BoxDecoration(
                            color: _getColorForSession(session),
                            border: Border.all(
                              color: _getColorForSession(session).withOpacity(0.3),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }

                    return Expanded(
                      child: Container(
                        height: cellHeight,
                        margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 0.5),
                        decoration: BoxDecoration(
                          color: session == null
                              ? Colors.white
                              : _getColorForSession(session),
                          border: Border.all(
                            color: session == null
                                ? Colors.grey[200]!
                                : _getColorForSession(session).withOpacity(0.3),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ],
              );
            }),
          ],
        ),
        // Merged blocks positioned on top
        ...mergedBlocks.map((block) {
          final session = block['session'] as Session;
          final dayIndex = block['dayIndex'] as int;
          final top = block['top'] as double;
          final height = block['height'] as double;
          final periodCount = block['periodCount'] as int;
          
          // Calculate left position: 46 (period label width) + dayIndex * cell width
          return Positioned(
            left: 46 + dayIndex * cellWidth,
            top: top,
            width: cellWidth,
            height: height,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 0.5),
              decoration: BoxDecoration(
                color: _getColorForSession(session),
                border: Border.all(
                  color: _getColorForSession(session).withOpacity(0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: _buildSessionCell(context, session, periodCount),
            ),
          );
        }),
          ],
        );
      },
    );
  }

  Widget? _buildSessionCell(BuildContext context, Session session, int periodCount) {
    // Show course name in merged block
    // Calculate max lines based on period count
    // Each period = 55px height, estimate ~10px per line with spacing
    final estimatedLinesPerPeriod = 4;
    final maxLines = periodCount * estimatedLinesPerPeriod;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSessionTap?.call(session),
        onLongPress: isEditing ? () => onSessionLongPress?.call(session) : null,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          width: double.infinity,
          height: double.infinity,
          decoration: isEditing
              ? BoxDecoration(
                  border: Border.all(
                    color: Colors.red.withOpacity(0.5),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                )
              : null,
          child: Center(
            child: Text(
              session.courseName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
        ),
      ),
    );
  }

  Color _getColorForSession(Session session) {
    // Color coding based on subject ID with better color palette
    final hash = session.subjectId.hashCode;
    final colors = [
      Colors.blue[50]!,      // Light blue
      Colors.green[50]!,     // Light green
      Colors.orange[50]!,    // Light orange
      Colors.purple[50]!,    // Light purple
      Colors.teal[50]!,      // Light teal
      Colors.pink[50]!,      // Light pink
      Colors.amber[50]!,     // Light amber
      Colors.cyan[50]!,      // Light cyan
      Colors.indigo[50]!,    // Light indigo
    ];
    return colors[hash.abs() % colors.length];
  }
}
