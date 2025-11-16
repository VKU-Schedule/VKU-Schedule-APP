import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/bottom_nav.dart';
import '../../../features/optimization/providers/optimization_provider.dart';
import '../../../features/optimization/providers/optimization_history_provider.dart';
import '../../../models/schedule_option.dart';
import '../../../models/optimization_history.dart';
import '../../../models/saved_schedule.dart';
import '../providers/chosen_option_provider.dart';
import '../providers/saved_schedules_provider.dart';
import 'option_card.dart';

class OptionsListPage extends ConsumerStatefulWidget {
  const OptionsListPage({super.key});

  @override
  ConsumerState<OptionsListPage> createState() => _OptionsListPageState();
}

class _OptionsListPageState extends ConsumerState<OptionsListPage> {
  String _sortBy = 'score';
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    final optionsAsync = ref.watch(optimizationProvider);
    final chosenOptionId = ref.watch(chosenOptionProvider);
    final savedSchedules = ref.watch(savedSchedulesProvider);
    final optimizationHistory = ref.watch(optimizationHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách phương án'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showSortDialog(context);
            },
          ),
        ],
      ),
      body: optionsAsync.when(
        data: (options) {
          // If no options from optimization, show optimization history
          if (options.isEmpty) {
            if (optimizationHistory.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.inbox,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có phương án nào',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text('Hãy chạy tối ưu hóa để tạo lịch học'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.go('/subjects'),
                      child: const Text('Bắt đầu tối ưu'),
                    ),
                  ],
                ),
              );
            }

            // Show optimization history with expand/collapse
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.history,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Lịch sử các lần tạo',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: optimizationHistory.length,
                    itemBuilder: (context, index) {
                      final history = optimizationHistory[index];
                      return _HistoryItem(
                        history: history,
                        chosenOptionId: chosenOptionId,
                        savedSchedules: savedSchedules,
                        onViewDetails: (option) {
                          ref
                              .read(chosenOptionProvider.notifier)
                              .selectOption(option);
                          context.go('/timetable');
                        },
                        onCompare: () {
                          context.push('/compare');
                        },
                        onSave: (option) async {
                          try {
                            await ref
                                .read(savedSchedulesProvider.notifier)
                                .saveSchedule(option);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã lưu phương án thành công'),
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
                        },
                        getScheduleOptions: (historyId) {
                          return ref
                              .read(optimizationHistoryProvider.notifier)
                              .getScheduleOptionsForHistory(historyId);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }

          final sortedOptions = _sortOptions(options);

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.list_alt,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Có ${options.length} phương án',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: sortedOptions.length,
                  itemBuilder: (context, index) {
                    final option = sortedOptions[index];
                    final isChosen = chosenOptionId?.id == option.id;
                    final isSaved = savedSchedules.any((saved) => saved.id == option.id);

                    return OptionCard(
                      option: option,
                      index: index + 1,
                      isChosen: isChosen,
                      isSaved: isSaved,
                      onSelect: () async {
                        try {
                          await ref
                              .read(savedSchedulesProvider.notifier)
                              .saveSchedule(option);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã lưu phương án thành công'),
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
                      },
                      onViewDetails: () {
                        // Set chosen option first, then navigate
                        ref
                            .read(chosenOptionProvider.notifier)
                            .selectOption(option);
                        context.go('/timetable');
                      },
                      onCompare: () {
                        context.push('/compare');
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Lỗi: $error',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/subjects'),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentRoute: '/options'),
    );
  }

  List<ScheduleOption> _sortOptions(List<ScheduleOption> options) {
    final sorted = List<ScheduleOption>.from(options);
    sorted.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'score':
          comparison = a.score.compareTo(b.score);
          break;
        case 'conflicts':
          comparison = a.metrics.conflicts.compareTo(b.metrics.conflicts);
          break;
        case 'morning':
          comparison = b.metrics.morningRatio.compareTo(a.metrics.morningRatio);
          break;
        case 'balance':
          comparison = b.metrics.balance.compareTo(a.metrics.balance);
          break;
        default:
          comparison = 0;
      }
      return _sortAscending ? comparison : -comparison;
    });
    return sorted;
  }

  void _showSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sắp xếp'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Điểm số'),
              value: 'score',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Số xung đột'),
              value: 'conflicts',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Tỷ lệ buổi sáng'),
              value: 'morning',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Cân bằng'),
              value: 'balance',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryItem extends StatefulWidget {
  final OptimizationHistory history;
  final ScheduleOption? chosenOptionId;
  final List<SavedSchedule> savedSchedules;
  final Function(ScheduleOption) onViewDetails;
  final VoidCallback onCompare;
  final Function(ScheduleOption) onSave;
  final List<ScheduleOption> Function(String) getScheduleOptions;

  const _HistoryItem({
    required this.history,
    required this.chosenOptionId,
    required this.savedSchedules,
    required this.onViewDetails,
    required this.onCompare,
    required this.onSave,
    required this.getScheduleOptions,
  });

  @override
  State<_HistoryItem> createState() => _HistoryItemState();
}

class _HistoryItemState extends State<_HistoryItem> {
  bool _isExpanded = false;
  List<ScheduleOption>? _options;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded && _options == null) {
        _options = widget.getScheduleOptions(widget.history.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              'Lần tạo ${dateFormat.format(widget.history.createdAt)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${widget.history.scheduleOptionIds.length} phương án',
            ),
            trailing: Icon(
              Icons.history,
              color: Colors.grey[400],
            ),
            onTap: _toggleExpand,
          ),
          if (_isExpanded && _options != null) ...[
            const Divider(height: 1),
            ..._options!.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isChosen = widget.chosenOptionId?.id == option.id;
              final isOptionSaved = widget.savedSchedules.any(
                (saved) => saved.id == option.id,
              );

              return OptionCard(
                option: option,
                index: index + 1,
                isChosen: isChosen,
                isSaved: isOptionSaved,
                onSelect: () => widget.onSave(option),
                onViewDetails: () => widget.onViewDetails(option),
                onCompare: widget.onCompare,
              );
            }),
          ],
        ],
      ),
    );
  }
}
