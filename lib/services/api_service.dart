import 'package:dio/dio.dart';
import 'package:vku_schedule/core/network/dio_client.dart';
import 'package:vku_schedule/models/api_subject.dart';
import 'package:vku_schedule/models/optimization_request.dart';
import 'package:vku_schedule/models/optimization_response.dart';

/// Service for API calls to backend server
class ApiService {
  final DioClient _dioClient;
  final DioClient _optimizationClient;

  ApiService({
    required DioClient dioClient,
    required DioClient optimizationClient,
  })  : _dioClient = dioClient,
        _optimizationClient = optimizationClient;

  /// Search subjects by query string
  /// Calls POST /api/search-recommend endpoint
  Future<List<ApiSubject>> searchSubjects(String query) async {
    try {
      final response = await _dioClient.instance.post(
        '/api/search-recommend',
        data: {'query': query},
      );

      if (response.statusCode == 200) {
        // API returns {query: "...", results: [...]}
        final responseData = response.data as Map<String, dynamic>;
        final List<dynamic> results = responseData['results'] as List<dynamic>;
        
        return results
            .map((json) => ApiSubject.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(
          'Tìm kiếm thất bại',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Lỗi không xác định: ${e.toString()}');
    }
  }


  /// Optimize schedule with NSGA-II algorithm
  /// Calls POST /api/convert endpoint with 60s timeout
  Future<OptimizationResponse> optimizeSchedule(
    OptimizationRequest request,
  ) async {
    print('[ApiService] optimizeSchedule() called');
    print('[ApiService] Request: ${request.toString()}');
    print('[ApiService] OptimizationClient baseUrl: ${_optimizationClient.instance.options.baseUrl}');
    
    try {
      // Log request data before sending
      final requestData = request.toJson();
      print('[ApiService] Request data converted to JSON');
      
      // Print formatted JSON for easy inspection
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('📤 OPTIMIZATION REQUEST TO API');
      print('═══════════════════════════════════════════════════════════');
      print('Endpoint: POST /api/convert');
      print('');
      print('📋 Request Data:');
      print('{');
      print('  "queries": [');
      final queries = requestData['queries'] as List<dynamic>;
      for (var i = 0; i < queries.length; i++) {
        final comma = i < queries.length - 1 ? ',' : '';
        print('    "${queries[i]}"$comma');
      }
      print('  ],');
      print('  "prompt": "${requestData['prompt']}"');
      print('}');
      print('');
      print('📊 Details:');
      print('  • Queries count: ${queries.length}');
      print('  • Prompt length: ${requestData['prompt'].toString().length} characters');
      print('');
      print('📝 Queries list:');
      for (var i = 0; i < queries.length; i++) {
        print('  [$i] "${queries[i]}"');
      }
      print('');
      print('💬 Prompt:');
      print('  "${requestData['prompt']}"');
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('');
      
      print('[ApiService] Sending POST request to /api/convert');
      print('[ApiService] Full URL: ${_optimizationClient.instance.options.baseUrl}/api/convert');
      print('[ApiService] Request data type: ${requestData.runtimeType}');
      print('[ApiService] Request data: $requestData');
      print('[ApiService] Timeout - Connect: ${_optimizationClient.instance.options.connectTimeout?.inSeconds ?? 0}s, Receive: ${_optimizationClient.instance.options.receiveTimeout?.inSeconds ?? 0}s');
      
      print('[ApiService] ⏳ Attempting to send request...');
      final response = await _optimizationClient.instance.post(
        '/api/convert',
        data: requestData,
        options: Options(
          validateStatus: (status) => status! < 500,
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
        ),
      );
      
      print('[ApiService] ✅ Response received! Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        
        // Check if response contains error
        if (data.containsKey('error')) {
          print('[ApiService] ❌ Response contains error field: ${data['error']}');
          throw ApiException(
            'Lỗi từ server: ${data['error']}',
            statusCode: 500,
          );
        }
        
        print('[ApiService] Parsing response to OptimizationResponse...');
        return OptimizationResponse.fromJson(data);
      } else {
        print('[ApiService] ❌ Response status code is not 200: ${response.statusCode}');
        throw ApiException(
          'Tối ưu hóa thất bại',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('[ApiService] ❌ DioException occurred!');
      print('[ApiService] Exception type: ${e.type}');
      print('[ApiService] Message: ${e.message}');
      print('[ApiService] Response: ${e.response?.statusCode} - ${e.response?.data}');
      print('[ApiService] Request path: ${e.requestOptions.path}');
      final exception = _handleDioError(e);
      print('[ApiService] Converted to ApiException: ${exception.message}');
      throw exception;
    } catch (e, stackTrace) {
      print('[ApiService] ❌ Unexpected error occurred!');
      print('[ApiService] Error: $e');
      print('[ApiService] StackTrace: $stackTrace');
      throw ApiException('Lỗi không xác định: ${e.toString()}');
    }
  }

  /// Handle Dio errors and convert to Vietnamese messages
  ApiException _handleDioError(DioException error) {
    print('[ApiService] _handleDioError() called with type: ${error.type}');
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          'Kết nối quá thời gian. Vui lòng thử lại.',
          statusCode: error.response?.statusCode,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        String message;

        switch (statusCode) {
          case 400:
            message = 'Yêu cầu không hợp lệ';
            break;
          case 401:
            message = 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại';
            break;
          case 403:
            message = 'Không có quyền truy cập';
            break;
          case 404:
            message = 'Không tìm thấy dữ liệu';
            break;
          case 500:
            message = 'Lỗi máy chủ. Vui lòng thử lại sau';
            break;
          default:
            message = 'Lỗi kết nối (Mã lỗi: $statusCode)';
        }

        return ApiException(message, statusCode: statusCode);

      case DioExceptionType.cancel:
        return ApiException('Yêu cầu đã bị hủy');

      case DioExceptionType.connectionError:
        return ApiException(
          'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.',
        );

      case DioExceptionType.badCertificate:
        return ApiException('Lỗi bảo mật kết nối');

      case DioExceptionType.unknown:
        return ApiException(
          'Lỗi kết nối: ${error.message ?? "Không xác định"}',
        );
    }
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message';
}
