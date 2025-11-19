import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../core/widgets/weekly_grid.dart';
import '../../../features/options/providers/chosen_option_provider.dart';
import '../../../features/options/providers/saved_schedules_provider.dart';
import '../../../models/session.dart';
import '../../../models/schedule_option.dart';
import '../../../services/timetable_export_service.dart';
import 'add_session_page.dart';
import 'session_details_sheet.dart';

class WeeklyTimetablePage extends ConsumerStatefulWidget {
  final ScheduleOption? chosenOption;
  
  const WeeklyTimetablePage({super.key, this.chosenOption});

  @override
  ConsumerState<WeeklyTimetablePage> createState() =>
      _WeeklyTimetablePageState();
}

class _WeeklyTimetablePageState extends ConsumerState<WeeklyTimetablePage> {
  DateTime _currentWeek = DateTime.now();
  bool _isEditing = false;
  List<Session>? _editingSessions;
  final List<List<Session>> _undoStack = [];
  final List<List<Session>> _redoStack = [];
  final GlobalKey _timetableKey = GlobalKey();
  final TimetableExportService _exportService = TimetableExportService();

  bool _isSavedSchedule(ScheduleOption? option) {
    if (option == null) return false;
    return ref.read(savedSchedulesProvider.notifier).isScheduleSaved(option.id);
  }

  void _pushToUndoStack() {
    if (_editingSessions != null) {
      _undoStack.add(List<Session>.from(_editingSessions!));
      _redoStack.clear();
    }
  }

  void _undo() {
    if (_undoStack.isNotEmpty) {
      _redoStack.add(List<Session>.from(_editingSessions!));
      setState(() {
        _editingSessions = _undoStack.removeLast();
      });
    }
  }

  void _redo() {
    if (_redoStack.isNotEmpty) {
      _undoStack.add(List<Session>.from(_editingSessions!));
      setState(() {
        _editingSessions = _redoStack.removeLast();
      });
    }
  }

  Future<void> _shareSchedule() async {
    final chosenOption = ref.read(chosenOptionProvider);
    if (chosenOption == null) return;

    try {
      final shareText = _exportService.generateShareText(chosenOption);
      await Clipboard.setData(ClipboardData(text: shareText));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã sao chép lịch học vào clipboard'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chia sẻ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportAsPdf() async {
    final chosenOption = ref.read(chosenOptionProvider);
    if (chosenOption == null) return;

    try {
      final html = _exportService.generatePdfHtml(chosenOption);
      await Clipboard.setData(ClipboardData(text: html));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã sao chép HTML vào clipboard. Bạn có thể dán vào trình duyệt và in thành PDF.'),
            duration: Duration(seconds: 4),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xuất PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _captureScreenshot() async {
    try {
      final imageBytes = await _exportService.captureAsImage(_timetableKey);
      if (imageBytes != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã chụp ảnh lịch học thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chụp ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showExportMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Xuất lịch học',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Chia sẻ dạng text'),
              onTap: () {
                Navigator.pop(context);
                _shareSchedule();
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Xuất PDF'),
              onTap: () {
                Navigator.pop(context);
                _exportAsPdf();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _captureScreenshot();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startEditing() {
    final chosenOption = ref.read(chosenOptionProvider);
    if (chosenOption != null) {
      setState(() {
        _isEditing = true;
        _editingSessions = List<Session>.from(chosenOption.sessions);
        _undoStack.clear();
        _redoStack.clear();
      });
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _editingSessions = null;
      _undoStack.clear();
      _redoStack.clear();
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
            const Text(
              'Bạn có chắc muốn xóa buổi học này?',
              style: TextStyle(fontWeight: FontWeight.bold),
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
              _pushToUndoStack();
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
      _pushToUndoStack();
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
        appBar: const VKUAppBar(
          title: 'Lịch tuần',
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
      appBar: VKUAppBar(
        title: _isEditing ? 'Chỉnh sửa lịch' : 'Lịch tuần',
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
            IconButton(
              icon: const Icon(Icons.ios_share),
              tooltip: 'Chia sẻ',
              onPressed: _showExportMenu,
            ),
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
      body: Stack(
        children: [
          Column(
            children: [
              // Edit mode indicator
              if (_isEditing)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.error,
                        Theme.of(context).colorScheme.error.withValues(alpha: 0.8),
                      ],
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Chế độ chỉnh sửa',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              // Week navigation with improved styling
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
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
                child: RepaintBoundary(
                  key: _timetableKey,
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
                        color: Colors.black.withValues(alpha: 0.05),
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
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Undo/Redo floating buttons (only in edit mode)
          if (_isEditing)
            Positioned(
              right: 16,
              bottom: 100,
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: 'undo',
                    mini: true,
                    onPressed: _undoStack.isEmpty ? null : _undo,
                    backgroundColor: _undoStack.isEmpty
                        ? Colors.grey[300]
                        : Theme.of(context).colorScheme.secondary,
                    child: Icon(
                      Icons.undo,
                      color: _undoStack.isEmpty ? Colors.grey : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: 'redo',
                    mini: true,
                    onPressed: _redoStack.isEmpty ? null : _redo,
                    backgroundColor: _redoStack.isEmpty
                        ? Colors.grey[300]
                        : Theme.of(context).colorScheme.secondary,
                    child: Icon(
                      Icons.redo,
                      color: _redoStack.isEmpty ? Colors.grey : Colors.black,
                    ),
                  ),
                ],
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
    // Find related sessions (same course)
    final relatedSessions = (_editingSessions ?? widget.chosenOption?.sessions ?? [])
        .where((s) =>
            s != session &&
            s.courseName == session.courseName)
        .toList();

    showSessionDetails(
      context,
      session,
      relatedSessions: relatedSessions,
      onEdit: _isEditing ? null : () {
        Navigator.pop(context);
        _startEditing();
      },
      onDelete: _isEditing ? () {
        Navigator.pop(context);
        _deleteSession(session);
      } : null,
      onShare: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tính năng chia sẻ đang phát triển')),
        );
      },
      onAddToCalendar: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tính năng thêm vào lịch đang phát triển')),
        );
      },
    );
  }
}
