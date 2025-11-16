import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/optimization/providers/optimization_provider.dart';
import '../../../features/options/providers/chosen_option_provider.dart';
import 'comparison_grid.dart';

class ComparisonPage extends ConsumerStatefulWidget {
  const ComparisonPage({super.key});

  @override
  ConsumerState<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends ConsumerState<ComparisonPage> {
  final Set<String> _selectedOptionIds = {};

  @override
  Widget build(BuildContext context) {
    final optionsAsync = ref.watch(optimizationProvider);
    final chosenOption = ref.watch(chosenOptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('So sánh lịch học'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Go back to options page
            context.go('/options');
          },
        ),
      ),
      body: optionsAsync.when(
        data: (options) {
          if (options.isEmpty) {
            return const Center(
              child: Text('Chưa có phương án để so sánh'),
            );
          }

          // Initialize selection with chosen option if available
          if (chosenOption != null && _selectedOptionIds.isEmpty) {
            _selectedOptionIds.add(chosenOption.id);
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
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.compare_arrows,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
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
