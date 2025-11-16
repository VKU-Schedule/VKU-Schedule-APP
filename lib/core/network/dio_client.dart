import 'package:dio/dio.dart';

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
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
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
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  /// Get default base URL
  static String _getDefaultBaseUrl() {
    // Using actual VKU API endpoints
    return 'http://20.106.16.223:8001';
  }

  /// Create a Dio client for optimization requests with longer timeout
  static DioClient createOptimizationClient({String? Function()? getAuthToken}) {
    final client = DioClient(getAuthToken: getAuthToken);
    client.setTimeouts(
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    );
    return client;
  }
}


