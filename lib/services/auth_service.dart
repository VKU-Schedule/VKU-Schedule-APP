import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vku_schedule/models/user_profile.dart';
import 'package:vku_schedule/services/local_storage_service.dart';

/// Service for handling authentication with Google Sign-In
class AuthService {
  final GoogleSignIn _googleSignIn;
  final LocalStorageService _localStorage;

  // Stream controller for auth state changes
  final _authStateController = StreamController<UserProfile?>.broadcast();

  // Current user cache
  UserProfile? _currentUser;

  AuthService({
    required LocalStorageService localStorage,
    GoogleSignIn? googleSignIn,
  })  : _localStorage = localStorage,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: [
                'email',
                'profile',
                'https://www.googleapis.com/auth/calendar',
              ],
            ) {
    // Load user from local storage on initialization
    _loadUserFromStorage();
  }

  /// Stream of authentication state changes
  Stream<UserProfile?> get authStateChanges => _authStateController.stream;

  /// Get current authenticated user
  UserProfile? get currentUser => _currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;

  /// Load user from local storage
  void _loadUserFromStorage() {
    try {
      final user = _localStorage.getUserProfile();
      if (user != null) {
        _currentUser = user;
        _authStateController.add(user);
      }
    } catch (e) {
      // Ignore errors during initialization
    }
  }

  /// Sign in with Google
  Future<UserProfile?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        throw AuthException('Đăng nhập bị hủy');
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Get auth token
      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw AuthException('Không thể lấy token xác thực');
      }

      // Create user profile from Google account
      final userProfile = UserProfile(
        name: googleUser.displayName ?? googleUser.email,
        email: googleUser.email,
        photoUrl: googleUser.photoUrl,
      );

      // Save user profile to local storage
      await _localStorage.saveUserProfile(userProfile);

      // Store auth tokens securely
      await _storeAuthTokens(accessToken, idToken);

      // Update current user and notify listeners
      _currentUser = userProfile;
      _authStateController.add(userProfile);

      return userProfile;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Đăng nhập thất bại: ${e.toString()}');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Google
      await _googleSignIn.signOut();

      // Clear user profile from local storage
      await _localStorage.deleteUserProfile();

      // Clear auth tokens
      await _clearAuthTokens();

      // Update current user and notify listeners
      _currentUser = null;
      _authStateController.add(null);
    } catch (e) {
      throw AuthException('Đăng xuất thất bại: ${e.toString()}');
    }
  }

  /// Get current auth token
  Future<String?> getAuthToken() async {
    try {
      // Check if user is signed in
      if (!await _googleSignIn.isSignedIn()) {
        return null;
      }

      // Get current Google user
      final GoogleSignInAccount? googleUser = _googleSignIn.currentUser;
      if (googleUser == null) {
        return null;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      return googleAuth.accessToken;
    } catch (e) {
      throw AuthException('Không thể lấy token: ${e.toString()}');
    }
  }

  /// Get ID token for server authentication
  Future<String?> getIdToken() async {
    try {
      // Check if user is signed in
      if (!await _googleSignIn.isSignedIn()) {
        return null;
      }

      // Get current Google user
      final GoogleSignInAccount? googleUser = _googleSignIn.currentUser;
      if (googleUser == null) {
        return null;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      return googleAuth.idToken;
    } catch (e) {
      throw AuthException('Không thể lấy ID token: ${e.toString()}');
    }
  }

  /// Refresh authentication token
  Future<String?> refreshToken() async {
    try {
      // Check if user is signed in
      if (!await _googleSignIn.isSignedIn()) {
        return null;
      }

      // Get current Google user
      final GoogleSignInAccount? googleUser = _googleSignIn.currentUser;
      if (googleUser == null) {
        return null;
      }

      // Clear cached authentication to force refresh
      await googleUser.clearAuthCache();

      // Get fresh authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;

      if (accessToken != null && idToken != null) {
        await _storeAuthTokens(accessToken, idToken);
      }

      return accessToken;
    } catch (e) {
      throw AuthException('Không thể làm mới token: ${e.toString()}');
    }
  }

  /// Check if user is signed in silently (without UI)
  Future<UserProfile?> signInSilently() async {
    try {
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signInSilently();

      if (googleUser == null) {
        return null;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;

      if (accessToken != null && idToken != null) {
        await _storeAuthTokens(accessToken, idToken);
      }

      // Load or create user profile
      UserProfile? userProfile = _localStorage.getUserProfile();
      if (userProfile == null) {
        userProfile = UserProfile(
          name: googleUser.displayName ?? googleUser.email,
          email: googleUser.email,
          photoUrl: googleUser.photoUrl,
        );
        await _localStorage.saveUserProfile(userProfile);
      }

      _currentUser = userProfile;
      _authStateController.add(userProfile);

      return userProfile;
    } catch (e) {
      // Silent sign-in failed, user needs to sign in manually
      return null;
    }
  }

  /// Store auth tokens securely in local storage
  Future<void> _storeAuthTokens(String accessToken, String idToken) async {
    try {
      // For now, we're relying on GoogleSignIn to manage tokens internally
      // In production, consider using flutter_secure_storage for better security
      // Note: AppSettings model would need to be extended to store tokens
      // This is a placeholder for future token storage implementation
    } catch (e) {
      // Log error but don't throw - token storage is not critical
    }
  }

  /// Clear auth tokens from local storage
  Future<void> _clearAuthTokens() async {
    try {
      // Clear tokens from storage
      // Implementation depends on how tokens are stored
    } catch (e) {
      // Log error but don't throw
    }
  }

  /// Dispose resources
  void dispose() {
    _authStateController.close();
  }
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
