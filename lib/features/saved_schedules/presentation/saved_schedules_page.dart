import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../models/saved_schedule.dart';
import '../../../models/schedule_option.dart';
import '../../options/providers/saved_schedules_provider.dart';
import '../../options/providers/chosen_option_provider.dart';
import '../../comparison/presentation/comparison_page.dart';

class SavedSchedulesPage extends ConsumerWidget {
  const SavedSchedulesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedSchedules = ref.watch(savedSchedulesProvider);
    
    // Nhóm schedules theo sessionId
    final Map<String?, List<SavedSchedule>> groupedSchedules = {};
    for (final schedule in savedSchedules) {
      final sessionId = schedule.sessionId ?? schedule.id; // Fallback to id if no sessionId
      groupedSchedules.putIfAbsent(sessionId, () => []).add(schedule);
    }

    return Scaffold(
      appBar: VKUAppBar(
        title: 'Lịch đã lưu',
        automaticallyImplyLeading: false, // Root page - no back button
        actions: [
          if (savedSchedules.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.read(savedSchedulesProvider.notifier).refresh();
              },
              tooltip: 'Làm mới',
            ),
        ],
      ),
      body: savedSchedules.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có lịch đã lưu',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lưu các phương án bạn muốn xem sau',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedSchedules.length,
              itemBuilder: (context, groupIndex) {
                final sessionId = groupedSchedules.keys.elementAt(groupIndex);
                final sessionSchedules = groupedSchedules[sessionId]!;
                
                // Nếu có nhiều hơn 1 schedule trong session, hiển thị header với button so sánh
                if (sessionSchedules.length > 1) {
                  return _SessionGroup(
                    sessionId: sessionId,
                    schedules: sessionSchedules,
                    groupIndex: groupIndex + 1,
                  );
                }
                
                // Nếu chỉ có 1 schedule, hiển thị card đơn
                final saved = sessionSchedules.first;
                final scheduleOption =
                    ref.read(savedSchedulesProvider.notifier).getScheduleOption(saved.id);

                return _SavedScheduleCard(
                  index: groupIndex + 1,
                  saved: saved,
                  scheduleOption: scheduleOption,
                  onView: () {
                    if (scheduleOption != null) {
                      ref
                          .read(chosenOptionProvider.notifier)
                          .selectOption(scheduleOption);
                      context.go('/timetable');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Không thể tải lịch này'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Xóa lịch đã lưu'),
                        content: const Text('Bạn có chắc muốn xóa lịch này?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Xóa'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      try {
                        await ref
                            .read(savedSchedulesProvider.notifier)
                            .deleteSchedule(saved.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã xóa lịch'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lỗi khi xóa: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                );
              },
            ),
      bottomNavigationBar: const BottomNavBar(currentRoute: '/saved-schedules'),
    );
  }
}

class _SessionGroup extends ConsumerWidget {
  final String? sessionId;
  final List<SavedSchedule> schedules;
  final int groupIndex;

  const _SessionGroup({
    required this.sessionId,
    required this.schedules,
    required this.groupIndex,
  });

  Future<void> _deleteAllSchedules(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tất cả lịch'),
        content: Text(
          'Bạn có chắc muốn xóa tất cả ${schedules.length} phương án trong lần tạo này?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        // Xóa tất cả schedules trong nhóm
        final ids = schedules.map((s) => s.id).toList();
        await ref
            .read(savedSchedulesProvider.notifier)
            .deleteMultipleSchedules(ids);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xóa ${schedules.length} phương án'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi xóa: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final createdAt = schedules.first.savedAt;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.folder_special,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lần tạo $groupIndex',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateFormat.format(createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${schedules.length} phương án',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Button xóa cả nhóm
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  tooltip: 'Xóa tất cả',
                  onPressed: () => _deleteAllSchedules(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            
            // Button so sánh
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Lấy tất cả schedule options
                  final options = schedules
                      .map((s) => ref.read(savedSchedulesProvider.notifier).getScheduleOption(s.id))
                      .where((option) => option != null)
                      .cast<ScheduleOption>()
                      .toList();
                  
                  if (options.length >= 2) {
                    // Navigate to comparison page với options
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ComparisonPage(
                          providedOptions: options,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cần ít nhất 2 phương án để so sánh'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.compare_arrows),
                label: const Text('So sánh các phương án'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Danh sách schedules
            ...schedules.asMap().entries.map((entry) {
              final index = entry.key;
              final saved = entry.value;
              final scheduleOption =
                  ref.read(savedSchedulesProvider.notifier).getScheduleOption(saved.id);
              
              return Padding(
                padding: EdgeInsets.only(top: index > 0 ? 12 : 0),
                child: _SavedScheduleCard(
                  index: index + 1,
                  saved: saved,
                  scheduleOption: scheduleOption,
                  isCompact: true,
                  onView: () {
                    if (scheduleOption != null) {
                      ref
                          .read(chosenOptionProvider.notifier)
                          .selectOption(scheduleOption);
                      context.go('/timetable');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Không thể tải lịch này'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Xóa lịch đã lưu'),
                        content: const Text('Bạn có chắc muốn xóa lịch này?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Xóa'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      try {
                        await ref
                            .read(savedSchedulesProvider.notifier)
                            .deleteSchedule(saved.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã xóa lịch'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lỗi khi xóa: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SavedScheduleCard extends StatelessWidget {
  final int index;
  final SavedSchedule saved;
  final dynamic scheduleOption; // ScheduleOption?
  final VoidCallback onView;
  final VoidCallback onDelete;
  final bool isCompact;

  const _SavedScheduleCard({
    required this.index,
    required this.saved,
    required this.scheduleOption,
    required this.onView,
    required this.onDelete,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final savedAtText = dateFormat.format(saved.savedAt);

    int sessionCount = 0;
    double score = 0.0;
    if (scheduleOption != null) {
      sessionCount = scheduleOption.sessions.length;
      score = scheduleOption.score;
    }

    return Card(
      margin: isCompact ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
      elevation: isCompact ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.bookmark,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phương án $index',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            savedAtText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (saved.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Đang dùng',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (scheduleOption != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    context,
                    Icons.event,
                    '$sessionCount buổi',
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    context,
                    Icons.star,
                    'Điểm: ${score.toStringAsFixed(1)}',
                    Colors.orange,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onView,
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('Xem lịch'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Xóa'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
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

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
