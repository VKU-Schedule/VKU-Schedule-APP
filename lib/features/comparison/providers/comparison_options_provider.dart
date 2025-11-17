import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/schedule_option.dart';

/// Temporary provider to store schedule options for comparison
/// Used when comparing options from history instead of current optimization
final comparisonOptionsProvider = StateProvider<List<ScheduleOption>?>((ref) => null);

