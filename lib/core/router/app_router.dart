import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/comparison/presentation/comparison_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/optimization/presentation/optimization_processing_page.dart';
import '../../features/options/presentation/options_list_page.dart';
import '../../features/preferences/presentation/preference_input_page.dart';
import '../../features/save_sync/presentation/save_sync_page.dart';
import '../../features/saved_schedules/presentation/saved_schedules_page.dart';
import '../../features/semester/presentation/semester_selection_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/subjects/presentation/subject_selection_page.dart';
import '../../features/timetable/presentation/weekly_timetable_page.dart';
import '../../features/weights/presentation/weight_configuration_page.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../models/user_profile.dart';
import '../di/providers.dart';

/// Router configuration with authentication guards
class AppRouter {
  final WidgetRef ref;

  AppRouter(this.ref);

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    // Remove refreshListenable to avoid auth provider interference
    // refreshListenable: GoRouterRefreshStream(
    //   ref.watch(authStateProvider.future).asStream(),
    // ),
    redirect: (context, state) {
      final localStorage = ref.read(localStorageServiceProvider);
      final location = state.uri.path;
      
      // Check if storage is initialized
      if (!localStorage.isInitialized) {
        print('[Router] Storage not initialized, staying at $location');
        return null;
      }

      // Check authentication from localStorage
      UserProfile? userProfile;
      bool isAuthenticated = false;
      bool hasCompletedOnboarding = false;
      
      try {
        userProfile = localStorage.getUserProfile();
        isAuthenticated = userProfile != null;
        hasCompletedOnboarding = localStorage.getSettings().hasCompletedOnboarding;
      } catch (e) {
        print('[Router] Error reading storage: $e');
        isAuthenticated = false;
        hasCompletedOnboarding = false;
      }

      print('[Router] Location: $location, Auth: $isAuthenticated, Onboarding: $hasCompletedOnboarding, User: ${userProfile?.email ?? 'null'}');

      // If not authenticated, only allow login and onboarding pages
      if (!isAuthenticated) {
        if (location != '/login' && location != '/') {
          print('[Router] Not authenticated, redirecting to /login');
          return '/login';
        }
        print('[Router] Not authenticated, staying at $location');
        return null;
      }

      // User is authenticated
      print('[Router] User is authenticated: ${userProfile?.email}');
      
      // If hasn't completed onboarding and not on onboarding page, redirect to onboarding
      if (!hasCompletedOnboarding && location != '/') {
        print('[Router] Onboarding not completed, redirecting to /');
        return '/';
      }

      // If authenticated and on login page, redirect to home
      if (location == '/login') {
        print('[Router] Already authenticated, redirecting to /home');
        return '/home';
      }

      // If completed onboarding and on onboarding page, redirect to home
      if (hasCompletedOnboarding && location == '/') {
        print('[Router] Authenticated and onboarded, redirecting to /home');
        return '/home';
      }

      print('[Router] No redirect needed, staying at $location');
      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/semester',
        builder: (context, state) => const SemesterSelectionPage(),
      ),
      GoRoute(
        path: '/subjects',
        builder: (context, state) => const SubjectSelectionPage(),
      ),
      GoRoute(
        path: '/preferences',
        builder: (context, state) => const PreferenceInputPage(),
      ),
      GoRoute(
        path: '/weights',
        builder: (context, state) => const WeightConfigurationPage(),
      ),
      GoRoute(
        path: '/optimize',
        builder: (context, state) => const OptimizationProcessingPage(),
      ),
      GoRoute(
        path: '/options',
        builder: (context, state) => const OptionsListPage(),
      ),
      GoRoute(
        path: '/compare',
        builder: (context, state) => const ComparisonPage(),
      ),
      GoRoute(
        path: '/timetable',
        builder: (context, state) => const WeeklyTimetablePage(),
      ),
      GoRoute(
        path: '/save-sync',
        builder: (context, state) => const SaveSyncPage(),
      ),
      GoRoute(
        path: '/saved-schedules',
        builder: (context, state) => const SavedSchedulesPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}




/// Helper class to convert Stream to Listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
