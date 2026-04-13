/// Centralized API configuration
/// Change these values to switch between environments
class ApiConfig {
  ApiConfig._();

  // Base URLs
  static const String mainApiBaseUrl = 'http://10.0.3.2:8001';
  static const String optimizationApiBaseUrl = 'http://10.0.3.2:5000';

  // Endpoints
  static const String searchRecommendEndpoint = '/api/search-recommend';
  static const String optimizeEndpoint = '/api/convert';

  // Timeouts
  static const Duration defaultTimeout = Duration(seconds: 10);
  static const Duration optimizationTimeout = Duration(seconds: 60);
}
