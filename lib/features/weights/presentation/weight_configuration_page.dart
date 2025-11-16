import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/weights_provider.dart';

class WeightConfigurationPage extends ConsumerWidget {
  const WeightConfigurationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weights = ref.watch(weightsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cấu hình trọng số'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Text(
              'Điều chỉnh trọng số cho các tiêu chí',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Giá trị từ 1 đến 6, càng cao thì tiêu chí càng quan trọng',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),
            _buildSlider(
              context,
              ref,
              'Giảng viên',
              weights.teacher,
              (value) {
                ref
                    .read(weightsProvider.notifier)
                    .updateWeight(teacher: value.toInt());
              },
            ),
            const SizedBox(height: 24),
            _buildSlider(
              context,
              ref,
              'Nhóm lớp',
              weights.classGroup,
              (value) {
                ref
                    .read(weightsProvider.notifier)
                    .updateWeight(classGroup: value.toInt());
              },
            ),
            const SizedBox(height: 24),
            _buildSlider(
              context,
              ref,
              'Ngày học',
              weights.day,
              (value) {
                ref
                    .read(weightsProvider.notifier)
                    .updateWeight(day: value.toInt());
              },
            ),
            const SizedBox(height: 24),
            _buildSlider(
              context,
              ref,
              'Tiết liên tiếp',
              weights.consecutive,
              (value) {
                ref
                    .read(weightsProvider.notifier)
                    .updateWeight(consecutive: value.toInt());
              },
            ),
            const SizedBox(height: 24),
            _buildSlider(
              context,
              ref,
              'Khoảng nghỉ',
              weights.rest,
              (value) {
                ref
                    .read(weightsProvider.notifier)
                    .updateWeight(rest: value.toInt());
              },
            ),
            const SizedBox(height: 24),
            _buildSlider(
              context,
              ref,
              'Phòng học',
              weights.room,
              (value) {
                ref
                    .read(weightsProvider.notifier)
                    .updateWeight(room: value.toInt());
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã lưu cấu hình trọng số'),
                  ),
                );
                context.go('/optimize');
              },
              child: const Text('Lưu và tiếp tục'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    BuildContext context,
    WidgetRef ref,
    String label,
    int value,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$value',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 6,
          divisions: 5,
          label: '$value',
          onChanged: onChanged,
        ),
      ],
    );
  }
}


