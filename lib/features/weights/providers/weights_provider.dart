import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/weights.dart';

class WeightsNotifier extends StateNotifier<Weights> {
  WeightsNotifier() : super(Weights());

  void updateWeight({
    int? teacher,
    int? classGroup,
    int? day,
    int? consecutive,
    int? rest,
    int? room,
  }) {
    state = state.copyWith(
      teacher: teacher,
      classGroup: classGroup,
      day: day,
      consecutive: consecutive,
      rest: rest,
      room: room,
    );
  }

  void reset() {
    state = Weights();
  }
}

final weightsProvider = StateNotifierProvider<WeightsNotifier, Weights>(
  (ref) => WeightsNotifier(),
);


