import 'package:dio/dio.dart';
import 'package:vku_schedule/core/config/api_config.dart';

/// Dio client for API requests with interceptors
class DioClient {
  late final Dio _dio;
  final String? Function()? getAuthToken;

  DioClient({
    String? baseUrl,
    this.getAuthToken,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? _getDefaultBaseUrl(),
        connectTimeout: ApiConfig.defaultTimeout,
        receiveTimeout: ApiConfig.defaultTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  /// Get the configured Dio instance
  Dio get instance => _dio;

  /// Setup interceptors for auth, logging, and error handling
  void _setupInterceptors() {
    // Auth token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token to headers if available
          if (getAuthToken != null) {
            final token = getAuthToken!();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized - token expired
          if (error.response?.statusCode == 401) {
            // Token refresh logic could be added here
            // For now, just pass the error through
          }
          return handler.next(error);
        },
      ),
    );

    // Logging interceptor (only in debug mode)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
        logPrint: (obj) {
          // Custom log print for better formatting
          // In production, consider using a proper logging package
          print('[DIO] $obj');
        },
      ),
    );
  }

  /// Update timeout for specific operations (e.g., optimization)
  void setTimeouts({
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) {
    if (connectTimeout != null) {
      _dio.options.connectTimeout = connectTimeout;
    }
    if (receiveTimeout != null) {
      _dio.options.receiveTimeout = receiveTimeout;
    }
  }

  /// Reset timeouts to default
  void resetTimeouts() {
    _dio.options.connectTimeout = ApiConfig.defaultTimeout;
    _dio.options.receiveTimeout = ApiConfig.defaultTimeout;
  }

  /// Get default base URL
  static String _getDefaultBaseUrl() {
    return ApiConfig.mainApiBaseUrl;
  }

  /// Create a Dio client for optimization requests with longer timeout
  static DioClient createOptimizationClient({String? Function()? getAuthToken}) {
    final client = DioClient(
      baseUrl: ApiConfig.optimizationApiBaseUrl,
      getAuthToken: getAuthToken,
    );
    client.setTimeouts(
      connectTimeout: ApiConfig.optimizationTimeout,
      receiveTimeout: ApiConfig.optimizationTimeout,
    );
    return client;
  }
}


