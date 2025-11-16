import '../../models/subject.dart';
import '../../services/api_service.dart';

class SubjectRepository {
  final ApiService _apiService;

  SubjectRepository(this._apiService);

  /// Search subjects using API
  Future<List<Subject>> searchSubjects(String query) async {
    // Call real API endpoint
    final apiSubjects = await _apiService.searchSubjects(query);
    
    // Convert ApiSubject to Subject
    return apiSubjects.map((apiSubject) {
      return Subject(
        courseName: apiSubject.courseName,
        subTopic: apiSubject.subTopic,
      );
    }).toList();
  }

  /// Get all subjects (deprecated - use searchSubjects instead)
  @Deprecated('Use searchSubjects instead')
  Future<List<Subject>> getSubjects(String semesterId) async {
    // Return empty list - should use search instead
    return [];
  }
}


