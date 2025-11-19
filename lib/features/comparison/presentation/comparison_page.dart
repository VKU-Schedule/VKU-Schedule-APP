import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_bar.dart';
import '../../../features/optimization/providers/optimization_provider.dart';
import '../../../features/options/providers/chosen_option_provider.dart';
import '../../../models/schedule_option.dart';
import 'comparison_grid.dart';

class ComparisonPage extends ConsumerStatefulWidget {
  final List<ScheduleOption>? providedOptions; // Options từ saved schedules
  
  const ComparisonPage({
    super.key,
    this.providedOptions,
  });

  @override
  ConsumerState<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends ConsumerState<ComparisonPage> {
  final Set<String> _selectedOptionIds = {};
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    // Sử dụng providedOptions nếu có, nếu không thì lấy từ optimization provider
    final optionsAsync = widget.providedOptions != null
        ? AsyncValue.data(widget.providedOptions!)
        : ref.watch(optimizationProvider);
    final chosenOption = ref.watch(chosenOptionProvider);

    return Scaffold(
      appBar: const VKUAppBar(
        title: 'So sánh lịch học',
      ),
      body: optionsAsync.when(
        data: (options) {
          if (options.isEmpty) {
            return const Center(
              child: Text('Chưa có phương án để so sánh'),
            );
          }

          // Initialize selection
          if (!_initialized) {
            _initialized = true;
            if (widget.providedOptions != null) {
              // Tự động chọn 2 phương án đầu tiên khi có providedOptions
              _selectedOptionIds.addAll(
                options.take(2).map((opt) => opt.id),
              );
            } else if (chosenOption != null) {
              // Chọn chosenOption nếu đến từ optimization flow
              _selectedOptionIds.add(chosenOption.id);
            }
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[100],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chọn 2-3 phương án để so sánh',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: options.take(5).toList().asMap().entries.map((entry) {
                        final index = entry.key;
                        final option = entry.value;
                        final isSelected = _selectedOptionIds.contains(option.id);
                        return FilterChip(
                          label: Text('Phương án ${index + 1}'),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                if (_selectedOptionIds.length < 3) {
                                  _selectedOptionIds.add(option.id);
                                }
                              } else {
                                _selectedOptionIds.remove(option.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _selectedOptionIds.length < 2
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.compare_arrows,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Chọn ít nhất 2 phương án để so sánh',
                            ),
                          ],
                        ),
                      )
                    : ComparisonGrid(
                        allOptions: options,
                        selectedOptions: options
                            .where((opt) =>
                                _selectedOptionIds.contains(opt.id))
                            .toList(),
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Lỗi: $error'),
        ),
      ),
    );
  }
}
