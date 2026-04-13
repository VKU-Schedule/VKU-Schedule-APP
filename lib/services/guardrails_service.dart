import 'package:dio/dio.dart';
import '../core/config/api_config.dart';
import '../core/network/dio_client.dart';
import '../core/validation/validation_result.dart';
import '../models/subject.dart';
import '../models/preference_constraints.dart';

/// Service for calling NeMo Guardrails validation API
class GuardrailsService {
  final DioClient _dioClient;

  GuardrailsService({required DioClient dioClient}) : _dioClient = dioClient;

  /// Validate prompt using NeMo Guardrails service
  /// Chỉ gửi prompt, AI sẽ tự phát hiện mọi vấn đề
  Future<ValidationResult> validatePrompt(String prompt) async {
    try {
      print('[GuardrailsService] Validating prompt via NeMo Guardrails...');
      
      final response = await _dioClient.instance.post(
        ApiConfig.validateEndpoint,
        data: {'prompt': prompt},
        options: Options(
          receiveTimeout: ApiConfig.validationTimeout,
          sendTimeout: ApiConfig.validationTimeout,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return _parseValidationResponse(data);
      } else {
        throw Exception('Validation failed with status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('[GuardrailsService] DioException: ${e.message}');
      // Fallback to ok if guardrails service is down
      return ValidationResult.ok();
    } catch (e) {
      print('[GuardrailsService] Error: $e');
      // Fallback to ok if any error occurs
      return ValidationResult.ok();
    }
  }

  ValidationResult _parseValidationResponse(Map<String, dynamic> data) {
    final isValid = data['is_valid'] as bool? ?? true;
    final severity = data['severity'] as String? ?? 'ok';
    final message = data['message'] as String?;
    final suggestion = data['suggestion'] as String?;
    final issuesData = data['issues'] as List<dynamic>? ?? [];

    final issues = issuesData
        .map((issue) => issue['message'] as String? ?? '')
        .where((msg) => msg.isNotEmpty)
        .toList();

    switch (severity) {
      case 'block':
        return ValidationResult.block(
          message: message ?? 'Đầu vào không hợp lệ',
          suggestion: suggestion,
          issues: issues,
        );
      case 'warn':
        return ValidationResult.warn(
          message: message ?? 'Có một số cảnh báo',
          suggestion: suggestion,
          issues: issues,
        );
      default:
        return ValidationResult.ok();
    }
  }
}
