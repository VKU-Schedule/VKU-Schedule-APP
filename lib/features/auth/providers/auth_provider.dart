import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vku_schedule/models/user_profile.dart';
import 'package:vku_schedule/services/auth_service.dart';
import 'package:vku_schedule/core/di/providers.dart';

final authStateProvider = StreamProvider<UserProfile?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

final currentUserProvider = Provider<UserProfile?>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  return localStorage.getUserProfile();
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

class AuthNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final AuthService _authService;
  final Ref ref;

  AuthNotifier(this._authService, this.ref) : super(const AsyncValue.loading()) {
    _initialize();
  }

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
      // Invalidate currentUserProvider to refresh UI
      ref.invalidate(currentUserProvider);
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
      // Invalidate currentUserProvider to refresh UI
      ref.invalidate(currentUserProvider);
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

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserProfile?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService, ref);
});


