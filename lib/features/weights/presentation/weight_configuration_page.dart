import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/vku_components.dart';
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
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          children: [
            Text(
              'Điều chỉnh trọng số cho các tiêu chí',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              'Giá trị từ 1 đến 6, càng cao thì tiêu chí càng quan trọng',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textLight,
                  ),
            ),
            const SizedBox(height: AppTheme.spaceXl),
            _buildSlider(
              context,
              ref,
              icon: Icons.person_outline,
              label: 'Giảng viên',
              description: 'Ưu tiên giảng viên phù hợp',
              value: weights.teacher,
              color: AppTheme.vkuRed,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                ref
                    .read(weightsProvider.notifier)
                    .updateWeight(teacher: value.toInt());
              },
            ),
            const SizedBox(height: AppTheme.spaceLg),
            _buildSlider(
              context,
              ref,
              icon: Icons.groups_outlined,
              label: 'Nhóm lớp',
              description: 'Học cùng nhóm bạn',
              value: weights.classGroup,
              color: AppTheme.vkuYellow800,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                ref
                    .read(weightsProvider.notifier)
                    .updateWeight(classGroup: value.toInt());
              },
            ),
            const SizedBox(height: AppTheme.spaceLg),
            _buildSlider(
              context,
              ref,
              icon: Icons.calendar_today_outlined,
              label: 'Ngày học',
              description: 'Phân bổ ngày học hợp lý',
              value: weights.day,
              color: AppTheme.vkuNavy,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                ref
                    .read(weightsProvider.notifier)
                    .updateWeight(day: value.toInt());
              },
            ),
            const SizedBox(height: AppTheme.spaceLg),
            _buildSlider(
              context,
              ref,
              icon: Icons.view_week_outlined,
              label: 'Tiết liên tiếp',
              description: 'Học các tiết liên tiếp nhau',
              value: weights.consecutive,
              color: AppTheme.vkuRed,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                ref
                    .read(weightsProvider.notifier)
                    .updateWeight(consecutive: value.toInt());
              },
            ),
            const SizedBox(height: AppTheme.spaceLg),
            _buildSlider(
              context,
              ref,
              icon: Icons.free_breakfast_outlined,
              label: 'Khoảng nghỉ',
              description: 'Có thời gian nghỉ giữa các tiết',
              value: weights.rest,
              color: AppTheme.vkuYellow800,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                ref
                    .read(weightsProvider.notifier)
                    .updateWeight(rest: value.toInt());
              },
            ),
            const SizedBox(height: AppTheme.spaceLg),
            _buildSlider(
              context,
              ref,
              icon: Icons.meeting_room_outlined,
              label: 'Phòng học',
              description: 'Phòng học thuận tiện',
              value: weights.room,
              color: AppTheme.vkuNavy,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                ref
                    .read(weightsProvider.notifier)
                    .updateWeight(room: value.toInt());
              },
            ),
            const SizedBox(height: AppTheme.spaceXl),
            VKUButton(
              text: 'Lưu và tiếp tục',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã lưu cấu hình trọng số'),
                    backgroundColor: AppTheme.success,
                  ),
                );
                context.go('/optimize');
              },
              fullWidth: true,
              useGradient: true,
              variant: VKUButtonVariant.primary,
              size: VKUButtonSize.large,
              icon: Icons.arrow_forward,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required String description,
    required int value,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return VKUCard(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceSm),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, AppTheme.lighten(color, 0.2)],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textLight,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, AppTheme.darken(color, 0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.2),
              overlayColor: color.withValues(alpha: 0.1),
              thumbColor: color,
              valueIndicatorColor: color,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Slider(
              value: value.toDouble(),
              min: 1,
              max: 6,
              divisions: 5,
              label: '$value',
              onChanged: onChanged,
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              final val = index + 1;
              return Text(
                '$val',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textLight.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
