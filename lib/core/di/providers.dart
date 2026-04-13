import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/subject_repository.dart';
import '../../services/optimization_service.dart';
import '../../services/local_storage_service.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../core/network/dio_client.dart';
import '../../core/config/api_config.dart';

// Storage Providers
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

final hiveBoxProvider = FutureProvider<Box>((ref) async {
  return await Hive.openBox('app_data');
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final localStorageInitProvider = FutureProvider<void>((ref) async {
  final service = ref.read(localStorageServiceProvider);
  await service.initialize();
});

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  return AuthService(localStorage: localStorage);
});

// Service Providers
final optimizationServiceProvider = Provider<OptimizationService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return OptimizationService(apiService);
});

// Dio Client Providers
final dioClientProvider = Provider<DioClient>((ref) {
  // Don't pass auth token for now - API doesn't require it
  return DioClient(
    getAuthToken: () => null,
  );
});

final optimizationDioClientProvider = Provider<DioClient>((ref) {
  final client = DioClient(
    baseUrl: ApiConfig.optimizationApiBaseUrl,
    getAuthToken: () => null,
  );
  client.setTimeouts(
    connectTimeout: ApiConfig.optimizationTimeout,
    receiveTimeout: ApiConfig.optimizationTimeout,
  );
  return client;
});

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final optimizationClient = ref.watch(optimizationDioClientProvider);
  return ApiService(
    dioClient: dioClient,
    optimizationClient: optimizationClient,
  );
});

// Repository Providers
final subjectRepositoryProvider = Provider<SubjectRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return SubjectRepository(apiService);
});


