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
                        '$period',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  ...List.generate(7, (day) {
                    final daySessions = sessions.where((s) =>
                        s.dayIndex == day &&
                        s.start <= period + 1 &&
                        s.end >= period + 1).toList();

                    if (daySessions.isEmpty) {
                      return Expanded(
                        child: Container(
                          height: 30,
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
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
                              ? Colors.red[100]
                              : _getColorForSession(session),
                          border: Border.all(
                            color: hasConflict
                                ? Colors.red
                                : Colors.grey[300]!,
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
                              color: hasConflict ? Colors.red[900] : null,
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

  Color _getColorForSession(Session session) {
    // Simple color coding based on subject ID hash
    final hash = session.subjectId.hashCode;
    final colors = [
      Colors.blue[100]!,
      Colors.green[100]!,
      Colors.orange[100]!,
      Colors.purple[100]!,
      Colors.teal[100]!,
    ];
    return colors[hash.abs() % colors.length];
  }
}

