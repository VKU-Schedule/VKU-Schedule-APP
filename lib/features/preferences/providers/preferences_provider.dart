import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/preference_constraints.dart';

class PreferencesNotifier extends StateNotifier<PreferenceConstraints> {
  PreferencesNotifier() : super(PreferenceConstraints());

  void updateConstraints(PreferenceConstraints constraints) {
    state = constraints;
  }

  void updatePromptText(String promptText) {
    state = state.copyWith(rawPromptText: promptText);
  }

  void reset() {
    state = PreferenceConstraints();
  }
}

final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, PreferenceConstraints>(
  (ref) => PreferencesNotifier(),
);


