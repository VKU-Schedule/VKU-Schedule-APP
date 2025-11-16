import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vku_schedule/models/user_profile.dart';
import 'package:vku_schedule/services/auth_service.dart';
import 'package:vku_schedule/core/di/providers.dart';

/// Stream provider for authentication state changes
final authStateProvider = StreamProvider<UserProfile?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider for current authenticated user
final currentUserProvider = Provider<UserProfile?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

/// State notifier for auth operations with loading states
class AuthNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _initialize();
  }

  /// Initialize by attempting silent sign-in
  Future<void> _initialize() async {
    try {
      final user = await _authService.signInSilently();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signInWithGoogle();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Get auth token
  Future<String?> getAuthToken() async {
    try {
      return await _authService.getAuthToken();
    } catch (e) {
      return null;
    }
  }

  /// Refresh token
  Future<String?> refreshToken() async {
    try {
      return await _authService.refreshToken();
    } catch (e) {
      return null;
    }
  }
}

/// Provider for auth operations
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserProfile?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});


