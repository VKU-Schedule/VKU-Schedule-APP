import 'package:flutter/material.dart';

import '../../../models/schedule_option.dart';
import '../../../models/session.dart';

class ComparisonGrid extends StatelessWidget {
  final List<ScheduleOption> allOptions;
  final List<ScheduleOption> selectedOptions;

  const ComparisonGrid({
    super.key,
    required this.allOptions,
    required this.selectedOptions,
  });

  /// Get index of option in allOptions list (1-based)
  int _getOptionIndex(ScheduleOption option) {
    final index = allOptions.indexWhere((opt) => opt.id == option.id);
    return index >= 0 ? index + 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: selectedOptions.map((option) {
          final optionIndex = _getOptionIndex(option);
          return Container(
            width: 300,
            margin: const EdgeInsets.all(8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phương án $optionIndex',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Điểm: ${option.score.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _buildWeeklyGrid(context, option.sessions),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeeklyGrid(BuildContext context, List<Session> sessions) {
    const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    const periods = 12;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Header
        Row(
          children: [
            const SizedBox(width: 40),
            ...days.map((day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )),
          ],
        ),
        const SizedBox(height: 4),
        // Grid
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: periods,
            itemBuilder: (context, period) {
              return Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(
                        '${period + 1}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  ...List.generate(7, (day) {
                    final daySessions = sessions.where((s) =>
                        s.dayIndex == day &&
                        s.startPeriod <= period + 1 &&
                        s.endPeriod >= period + 1).toList();

                    if (daySessions.isEmpty) {
                      return Expanded(
                        child: Container(
                          height: 30,
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark 
                                  ? const Color(0xFF2F2F2F)
                                  : const Color(0xFFE0E0E0),
                            ),
                          ),
                        ),
                      );
                    }

                    final session = daySessions.first;
                    final hasConflict = daySessions.length > 1;

                    return Expanded(
                      child: Container(
                        height: 30,
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: hasConflict
                              ? (isDark ? const Color(0xFFB71C1C) : const Color(0xFFFFCDD2))
                              : _getColorForSession(session, isDark),
                          border: Border.all(
                            color: hasConflict
                                ? (isDark ? const Color(0xFFFF6B6B) : const Color(0xFFD32F2F))
                                : (isDark ? const Color(0xFF2F2F2F) : const Color(0xFFE0E0E0)),
                            width: hasConflict ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            session.room,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: hasConflict 
                                  ? (isDark ? const Color(0xFFFFCDD2) : const Color(0xFFB71C1C))
                                  : null,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getColorForSession(Session session, bool isDark) {
    // Simple color coding based on subject ID hash
    final hash = session.subjectId.hashCode;
    final lightColors = [
      const Color(0xFFBBDEFB), // blue[100]
      const Color(0xFFC8E6C9), // green[100]
      const Color(0xFFFFE0B2), // orange[100]
      const Color(0xFFE1BEE7), // purple[100]
      const Color(0xFFB2DFDB), // teal[100]
    ];
    final darkColors = [
      const Color(0xFF1565C0), // blue dark
      const Color(0xFF2E7D32), // green dark
      const Color(0xFFE65100), // orange dark
      const Color(0xFF6A1B9A), // purple dark
      const Color(0xFF00695C), // teal dark
    ];
    final colors = isDark ? darkColors : lightColors;
    return colors[hash.abs() % colors.length];
  }
}
