import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/app_settings.dart';
import '../../../services/local_storage_service.dart';
import '../../../core/di/providers.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  return SettingsNotifier(localStorage);
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final LocalStorageService _localStorage;

  SettingsNotifier(this._localStorage) : super(AppSettings()) {
    _loadSettings();
  }

  void _loadSettings() {
    try {
      state = _localStorage.getSettings();
    } catch (e) {
      state = AppSettings();
    }
  }

  Future<void> updateThemeMode(String themeMode) async {
    try {
      await _localStorage.updateSetting(themeMode: themeMode);
      state = state.copyWith(themeMode: themeMode);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateNotifications(bool enabled) async {
    try {
      await _localStorage.updateSetting(notificationsEnabled: enabled);
      state = state.copyWith(notificationsEnabled: enabled);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateOnboardingStatus(bool completed) async {
    try {
      await _localStorage.updateSetting(hasCompletedOnboarding: completed);
      state = state.copyWith(hasCompletedOnboarding: completed);
    } catch (e) {
      rethrow;
    }
  }

  void refresh() {
    _loadSettings();
  }
}
