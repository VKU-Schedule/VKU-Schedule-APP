import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/subject_repository.dart';
import '../../services/optimization_service.dart';
import '../../services/local_storage_service.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../core/network/dio_client.dart';

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
  // Optimization API uses different base URL and longer timeout
  final client = DioClient(
    baseUrl: 'http://20.106.16.223:5000',
    getAuthToken: () => null, // API doesn't require auth for now
  );
  client.setTimeouts(
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
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


