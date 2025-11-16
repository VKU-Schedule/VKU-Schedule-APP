import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/bottom_nav.dart';
import '../../../core/widgets/weekly_grid.dart';
import '../../../features/options/providers/chosen_option_provider.dart';
import '../../../features/options/providers/saved_schedules_provider.dart';
import '../../../models/session.dart';
import '../../../models/schedule_option.dart';
import 'add_session_page.dart';

class WeeklyTimetablePage extends ConsumerStatefulWidget {
  const WeeklyTimetablePage({super.key});

  @override
  ConsumerState<WeeklyTimetablePage> createState() =>
      _WeeklyTimetablePageState();
}

class _WeeklyTimetablePageState extends ConsumerState<WeeklyTimetablePage> {
  DateTime _currentWeek = DateTime.now();
  bool _isEditing = false;
  List<Session>? _editingSessions; // Temporary sessions during editing

  bool _isSavedSchedule(ScheduleOption? option) {
    if (option == null) return false;
    return ref.read(savedSchedulesProvider.notifier).isScheduleSaved(option.id);
  }

  void _startEditing() {
    final chosenOption = ref.read(chosenOptionProvider);
    if (chosenOption != null) {
      setState(() {
        _isEditing = true;
        _editingSessions = List<Session>.from(chosenOption.sessions);
      });
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _editingSessions = null;
    });
  }

  Future<void> _saveChanges() async {
    final chosenOption = ref.read(chosenOptionProvider);
    if (chosenOption == null || _editingSessions == null) return;

    try {
      // Create updated schedule option
      final updatedOption = chosenOption.copyWith(
        sessions: _editingSessions!,
      );
      
      // Recalculate metrics
      final metrics = ScheduleOption.calculateMetrics(_editingSessions!);
      final finalOption = updatedOption.copyWith(metrics: metrics);

      // Update saved schedule
      await ref.read(savedSchedulesProvider.notifier).updateSchedule(
        chosenOption.id,
        finalOption,
      );

      // Update chosen option provider
      ref.read(chosenOptionProvider.notifier).selectOption(finalOption);

      if (mounted) {
        setState(() {
          _isEditing = false;
          _editingSessions = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu thay đổi thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteSession(Session session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa buổi học'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn có chắc muốn xóa buổi học này?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Môn: ${session.courseName}'),
            Text('Thời gian: ${session.dayName}, ${session.periodRange}'),
            Text('Phòng: ${session.room}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _editingSessions?.removeWhere((s) => s == session);
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Future<void> _addSession() async {
    final result = await Navigator.push<Session>(
      context,
      MaterialPageRoute(
        builder: (context) => AddSessionPage(
          currentSessions: _editingSessions ?? [],
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _editingSessions?.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chosenOption = ref.watch(chosenOptionProvider);
    final isSaved = _isSavedSchedule(chosenOption);
    final displaySessions = _isEditing && _editingSessions != null
        ? _editingSessions!
        : chosenOption?.sessions ?? [];

    if (chosenOption == null || chosenOption.sessions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Lịch tuần'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Chưa có lịch học',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('Hãy chọn một phương án từ danh sách'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Navigate to options
                },
                child: const Text('Chọn phương án'),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavBar(currentRoute: '/timetable'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa lịch' : 'Lịch tuần'),
        elevation: 0,
        actions: [
          if (_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.cancel),
              tooltip: 'Hủy',
              onPressed: _cancelEditing,
            ),
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Lưu',
              onPressed: _saveChanges,
            ),
          ] else ...[
            if (isSaved)
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Chỉnh sửa',
                onPressed: _startEditing,
              ),
            IconButton(
              icon: const Icon(Icons.today),
              tooltip: 'Về tuần hiện tại',
              onPressed: () {
                setState(() {
                  _currentWeek = DateTime.now();
                });
              },
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Week navigation with improved styling
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _currentWeek = _currentWeek.subtract(
                        const Duration(days: 7),
                      );
                    });
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Tuần ${_getWeekNumber(_currentWeek)} - ${_formatDateRange(_currentWeek)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _currentWeek = _currentWeek.add(
                        const Duration(days: 7),
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          // Weekly grid
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: WeeklyGrid(
                  sessions: displaySessions,
                  currentWeek: _currentWeek,
                  isEditing: _isEditing,
                  onSessionTap: (session) {
                    _showSessionDetails(context, session);
                  },
                  onSessionLongPress: _isEditing ? _deleteSession : null,
                ),
              ),
            ),
          ),
          
          // Add session button (only in edit mode)
          if (_isEditing)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addSession,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm môn học'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentRoute: '/timetable'),
    );
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil() + 1;
  }

  String _formatDateRange(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    return '${_formatDate(weekStart)} - ${_formatDate(weekEnd)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  void _showSessionDetails(BuildContext context, Session session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi tiết buổi học'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tên lớp: ${session.courseName}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Text('Phòng: ${session.room}'),
            const SizedBox(height: 8),
            Text('Giảng viên: ${session.instructor}'),
            const SizedBox(height: 8),
            Text('Nhóm: ${session.group}'),
            const SizedBox(height: 8),
            Text('Thời gian: ${session.dayName}, Tiết ${session.start}-${session.end}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
