import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/schedule_option.dart';

class ScheduleFilter {
  final double minScore;
  final double maxScore;
  final int? maxConflicts;
  final double? minMorningRatio;
  final double? minBalance;
  final bool showFavoritesOnly;

  const ScheduleFilter({
    this.minScore = 0.0,
    this.maxScore = 1.0,
    this.maxConflicts,
    this.minMorningRatio,
    this.minBalance,
    this.showFavoritesOnly = false,
  });

  ScheduleFilter copyWith({
    double? minScore,
    double? maxScore,
    int? maxConflicts,
    double? minMorningRatio,
    double? minBalance,
    bool? showFavoritesOnly,
  }) {
    return ScheduleFilter(
      minScore: minScore ?? this.minScore,
      maxScore: maxScore ?? this.maxScore,
      maxConflicts: maxConflicts ?? this.maxConflicts,
      minMorningRatio: minMorningRatio ?? this.minMorningRatio,
      minBalance: minBalance ?? this.minBalance,
      showFavoritesOnly: showFavoritesOnly ?? this.showFavoritesOnly,
    );
  }

  bool matches(ScheduleOption option) {
    if (option.score < minScore || option.score > maxScore) {
      return false;
    }
    if (maxConflicts != null && option.metrics.conflicts > maxConflicts!) {
      return false;
    }
    if (minMorningRatio != null &&
        option.metrics.morningRatio < minMorningRatio!) {
      return false;
    }
    if (minBalance != null && option.metrics.balance < minBalance!) {
      return false;
    }
    if (showFavoritesOnly && !option.isFavorite) {
      return false;
    }
    return true;
  }

  int get activeFilterCount {
    int count = 0;
    if (minScore > 0.0 || maxScore < 1.0) count++;
    if (maxConflicts != null) count++;
    if (minMorningRatio != null) count++;
    if (minBalance != null) count++;
    if (showFavoritesOnly) count++;
    return count;
  }

  bool get hasActiveFilters => activeFilterCount > 0;

  void reset() {}
}

class FilterNotifier extends StateNotifier<ScheduleFilter> {
  FilterNotifier() : super(const ScheduleFilter());

  void setScoreRange(double min, double max) {
    state = state.copyWith(minScore: min, maxScore: max);
  }

  void setMaxConflicts(int? max) {
    state = state.copyWith(maxConflicts: max);
  }

  void setMinMorningRatio(double? min) {
    state = state.copyWith(minMorningRatio: min);
  }

  void setMinBalance(double? min) {
    state = state.copyWith(minBalance: min);
  }

  void toggleFavoritesOnly() {
    state = state.copyWith(showFavoritesOnly: !state.showFavoritesOnly);
  }

  void reset() {
    state = const ScheduleFilter();
  }

  void applyPreset(FilterPreset preset) {
    switch (preset) {
      case FilterPreset.noConflicts:
        state = const ScheduleFilter(maxConflicts: 0);
        break;
      case FilterPreset.morningClasses:
        state = const ScheduleFilter(minMorningRatio: 0.7);
        break;
      case FilterPreset.balanced:
        state = const ScheduleFilter(minBalance: 0.7);
        break;
      case FilterPreset.highScore:
        state = const ScheduleFilter(minScore: 0.7);
        break;
    }
  }
}

enum FilterPreset {
  noConflicts,
  morningClasses,
  balanced,
  highScore,
}

final filterProvider = StateNotifierProvider<FilterNotifier, ScheduleFilter>(
  (ref) => FilterNotifier(),
);

final filteredOptionsProvider = Provider<List<ScheduleOption>>((ref) {
  // This will be replaced with actual optimization provider
  final optionsProvider = StateProvider<List<ScheduleOption>>((ref) => []);
  final options = ref.watch(optionsProvider);
  final filter = ref.watch(filterProvider);

  if (!filter.hasActiveFilters) {
    return options;
  }

  return options.where((option) => filter.matches(option)).toList();
});
