import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../models/subject.dart';

// Search provider - takes query as parameter
final subjectSearchProvider = FutureProvider.family<List<Subject>, String>((ref, query) async {
  if (query.isEmpty) {
    return []; // Return empty list if no query
  }
  
  final repository = ref.watch(subjectRepositoryProvider);
  return repository.searchSubjects(query);
});

// Default subjects provider - returns empty list (use search instead)
final subjectsProvider = FutureProvider<List<Subject>>((ref) async {
  return []; // Return empty - user should search
});

class SubjectSelectionState {
  final Set<String> enrolledSubjects;
  final Set<String> skippedSubjects;
  final Map<String, Subject> subjectCache; // Cache of all subjects by ID

  SubjectSelectionState({
    this.enrolledSubjects = const {},
    this.skippedSubjects = const {},
    this.subjectCache = const {},
  });

  SubjectSelectionState copyWith({
    Set<String>? enrolledSubjects,
    Set<String>? skippedSubjects,
    Map<String, Subject>? subjectCache,
  }) {
    return SubjectSelectionState(
      enrolledSubjects: enrolledSubjects ?? this.enrolledSubjects,
      skippedSubjects: skippedSubjects ?? this.skippedSubjects,
      subjectCache: subjectCache ?? this.subjectCache,
    );
  }

  /// Get enrolled subjects as Subject objects
  List<Subject> getEnrolledSubjects() {
    return enrolledSubjects
        .map((id) => subjectCache[id])
        .whereType<Subject>()
        .toList();
  }
}

class SubjectSelectionNotifier extends StateNotifier<SubjectSelectionState> {
  SubjectSelectionNotifier() : super(SubjectSelectionState());

  void toggleEnroll(String subjectId, {Subject? subject}) {
    final current = state;
    final newEnrolled = Set<String>.from(current.enrolledSubjects);
    final newSkipped = Set<String>.from(current.skippedSubjects);
    final newCache = Map<String, Subject>.from(current.subjectCache);

    if (newEnrolled.contains(subjectId)) {
      newEnrolled.remove(subjectId);
    } else {
      newEnrolled.add(subjectId);
      newSkipped.remove(subjectId);
      // Cache the subject if provided
      if (subject != null) {
        newCache[subjectId] = subject;
      }
    }

    state = state.copyWith(
      enrolledSubjects: newEnrolled,
      skippedSubjects: newSkipped,
      subjectCache: newCache,
    );
  }

  void toggleSkip(String subjectId, {Subject? subject}) {
    final current = state;
    final newEnrolled = Set<String>.from(current.enrolledSubjects);
    final newSkipped = Set<String>.from(current.skippedSubjects);
    final newCache = Map<String, Subject>.from(current.subjectCache);

    if (newSkipped.contains(subjectId)) {
      newSkipped.remove(subjectId);
    } else {
      newSkipped.add(subjectId);
      newEnrolled.remove(subjectId);
      // Cache the subject if provided
      if (subject != null) {
        newCache[subjectId] = subject;
      }
    }

    state = state.copyWith(
      enrolledSubjects: newEnrolled,
      skippedSubjects: newSkipped,
      subjectCache: newCache,
    );
  }
}

final subjectSelectionProvider =
    StateNotifierProvider<SubjectSelectionNotifier, SubjectSelectionState>(
  (ref) => SubjectSelectionNotifier(),
);


