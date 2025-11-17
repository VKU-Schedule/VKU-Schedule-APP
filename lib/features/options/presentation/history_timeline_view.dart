import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/vku_badge.dart';
import '../../../models/optimization_history.dart';
import '../../../models/schedule_option.dart';
import '../../../models/saved_schedule.dart';
import 'option_card.dart';

class HistoryTimelineView extends StatelessWidget {
  final List<OptimizationHistory> history;
  final ScheduleOption? chosenOption;
  final List<SavedSchedule> savedSchedules;
  final Function(ScheduleOption) onViewDetails;
  final Function(List<ScheduleOption>) onCompare;
  final Function(ScheduleOption) onSave;
  final List<ScheduleOption> Function(String) getScheduleOptions;

  const HistoryTimelineView({
    super.key,
    required this.history,
    required this.chosenOption,
    required this.savedSchedules,
    required this.onViewDetails,
    required this.onCompare,
    required this.onSave,
    required this.getScheduleOptions,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        final isLast = index == history.length - 1;

        return _HistoryTimelineItem(
          history: item,
          isLast: isLast,
          chosenOption: chosenOption,
          savedSchedules: savedSchedules,
          onViewDetails: onViewDetails,
          onCompare: onCompare,
          onSave: onSave,
          getScheduleOptions: getScheduleOptions,
        );
      },
    );
  }
}

class _HistoryTimelineItem extends StatefulWidget {
  final OptimizationHistory history;
  final bool isLast;
  final ScheduleOption? chosenOption;
  final List<SavedSchedule> savedSchedules;
  final Function(ScheduleOption) onViewDetails;
  final Function(List<ScheduleOption>) onCompare;
  final Function(ScheduleOption) onSave;
  final List<ScheduleOption> Function(String) getScheduleOptions;

  const _HistoryTimelineItem({
    required this.history,
    required this.isLast,
    required this.chosenOption,
    required this.savedSchedules,
    required this.onViewDetails,
    required this.onCompare,
    required this.onSave,
    required this.getScheduleOptions,
  });

  @override
  State<_HistoryTimelineItem> createState() => _HistoryTimelineItemState();
}

class _HistoryTimelineItemState extends State<_HistoryTimelineItem>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  List<ScheduleOption>? _options;
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
        if (_options == null) {
          _options = widget.getScheduleOptions(widget.history.id);
        }
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppTheme.gradientRedToNavy,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.vkuRed.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.history,
                color: Colors.white,
                size: 20,
              ),
            ),
            if (!widget.isLast)
              Container(
                width: 2,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.vkuRed.withValues(alpha: 0.5),
                      AppTheme.vkuNavy.withValues(alpha: 0.3),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: AppTheme.spaceMd),
        // Content
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
            decoration: AppTheme.glassmorphism(
              borderRadius: AppTheme.radiusMd,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleExpand,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dateFormat.format(widget.history.createdAt),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                VKUBadge(
                                  text:
                                      '${widget.history.scheduleOptionIds.length} phương án',
                                  variant: VKUBadgeVariant.navy,
                                  icon: Icons.list_alt,
                                  size: 6,
                                ),
                              ],
                            ),
                          ),
                          RotationTransition(
                            turns: _rotationAnimation,
                            child: Icon(
                              Icons.expand_more,
                              color: AppTheme.vkuRed,
                            ),
                          ),
                        ],
                      ),
                      // Expanded content
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: _buildExpandedContent(),
                        crossFadeState: _isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    if (_options == null) {
      return const Padding(
        padding: EdgeInsets.all(AppTheme.spaceMd),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_options!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppTheme.spaceMd),
        child: Text('Không có phương án nào'),
      );
    }

    return Column(
      children: [
        const Divider(height: AppTheme.spaceLg),
        ..._options!.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isChosen = widget.chosenOption?.id == option.id;
          final isSaved = widget.savedSchedules.any(
            (saved) => saved.id == option.id,
          );

          return Padding(
            padding: const EdgeInsets.only(top: AppTheme.spaceSm),
            child: OptionCard(
              option: option,
              index: index + 1,
              isChosen: isChosen,
              isSaved: isSaved,
              onSelect: () => widget.onSave(option),
              onViewDetails: () => widget.onViewDetails(option),
              onCompare: () {
                // Get all options for this history item and pass to onCompare
                final options = widget.getScheduleOptions(widget.history.id);
                widget.onCompare(options);
              },
            ),
          );
        }),
      ],
    );
  }
}
