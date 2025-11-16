import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/schedule_option.dart';

class ChosenOptionNotifier extends StateNotifier<ScheduleOption?> {
  ChosenOptionNotifier() : super(null);

  void selectOption(ScheduleOption option) {
    state = option;
  }

  void clear() {
    state = null;
  }
}

final chosenOptionProvider =
    StateNotifierProvider<ChosenOptionNotifier, ScheduleOption?>(
  (ref) => ChosenOptionNotifier(),
);
