import '../models/schedule_option.dart';
import '../models/subject.dart';
import '../models/weights.dart';
import '../models/preference_constraints.dart';
import '../models/optimization_request.dart';
import 'api_service.dart';

class OptimizationService {
  final ApiService _apiService;

  OptimizationService(this._apiService);

  Future<List<ScheduleOption>> optimize({
    required List<Subject> selectedSubjects,
    required PreferenceConstraints constraints,
    required Weights weights,
  }) async {
    print('[OptimizationService] optimize() called');
    print('[OptimizationService] Subjects count: ${selectedSubjects.length}');
    print('[OptimizationService] Has rawPromptText: ${constraints.rawPromptText != null && constraints.rawPromptText!.trim().isNotEmpty}');
    
    // Build queries list from selected subjects
    // Each query should be just courseName (subTopic is usually empty from API)
    final queries = selectedSubjects
        .map((subject) => subject.courseName)
        .toSet() // Remove duplicates
        .toList();

    print('[OptimizationService] Queries built: ${queries.length} items');
    for (var i = 0; i < queries.length; i++) {
      print('[OptimizationService]   [$i] "${queries[i]}"');
    }

    // Build prompt: use rawPromptText if available, otherwise build from constraints
    final prompt = constraints.rawPromptText?.trim().isNotEmpty == true
        ? constraints.rawPromptText!
        : _buildPrompt(constraints, weights);
    
    print('[OptimizationService] Prompt: "$prompt"');

    // Create request
    final request = OptimizationRequest(
      queries: queries,
      prompt: prompt,
    );

    // Log full request before sending
    print('');
    print('========================================');
    print('OPTIMIZATION REQUEST TO SERVER');
    print('========================================');
    print('Endpoint: http://20.106.16.223:5000/api/convert');
    print('');
    print('Queries (${queries.length} môn học):');
    for (var i = 0; i < queries.length; i++) {
      print('  [$i] "${queries[i]}"');
    }
    print('');
    print('Prompt:');
    print('  "$prompt"');
    print('');
    print('Full JSON:');
    print('  {');
    print('    "queries": [');
    for (var i = 0; i < queries.length; i++) {
      final comma = i < queries.length - 1 ? ',' : '';
      print('      "${queries[i]}"$comma');
    }
    print('    ],');
    print('    "prompt": "$prompt"');
    print('  }');
    print('========================================');
    print('');

    try {
      print('[OptimizationService] Calling ApiService.optimizeSchedule()...');
      print('[OptimizationService] ApiService instance: ${_apiService.runtimeType}');
      // Call API
      final response = await _apiService.optimizeSchedule(request);

      print('[OptimizationService] API call successful! Received ${response.schedules.length} schedules');

      // Convert API response to ScheduleOption list
      return response.schedules.map((apiSchedule) {
        return ScheduleOption.fromApiScheduleOption(apiSchedule);
      }).toList();
    } catch (e, stackTrace) {
      print('[OptimizationService] ❌ API Error occurred!');
      print('[OptimizationService] Error: $e');
      print('[OptimizationService] StackTrace: $stackTrace');
      
      // TODO: Remove this mock data when API is ready
      // Return empty list for now - user will see error message
      rethrow;
    }
  }

  /// Build prompt string from constraints and weights
  String _buildPrompt(PreferenceConstraints constraints, Weights weights) {
    final parts = <String>[];

    // Add morning preference
    if (constraints.morningPreferred) {
      parts.add('Ưu tiên buổi sáng');
    }

    // Add day preferences
    if (constraints.noDays.isNotEmpty) {
      final dayNames = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];
      final days = constraints.noDays.map((d) => dayNames[d]).join(', ');
      parts.add('Tránh các ngày: $days');
    }

    // Add time window preferences
    if (constraints.timeWindows.isNotEmpty) {
      parts.add('Có ${constraints.timeWindows.length} khung giờ ưu tiên');
    }

    // Add instructor preferences
    if (constraints.avoidInstructors.isNotEmpty) {
      parts.add('Tránh giảng viên: ${constraints.avoidInstructors.join(", ")}');
    }

    // Add consecutive periods constraint
    if (constraints.maxConsecutivePeriods != null) {
      parts.add('Tối đa ${constraints.maxConsecutivePeriods} tiết liên tiếp');
    }

    // Add rest interval constraint
    if (constraints.minRestInterval != null) {
      parts.add('Nghỉ tối thiểu ${constraints.minRestInterval} tiết');
    }

    // Add weights information
    parts.add('Trọng số: Giáo viên=${weights.teacher}, Nhóm=${weights.classGroup}, Ngày=${weights.day}, Liên tiếp=${weights.consecutive}, Nghỉ=${weights.rest}, Phòng=${weights.room}');

    return parts.isNotEmpty ? parts.join('. ') : 'Không có ràng buộc đặc biệt';
  }
}


