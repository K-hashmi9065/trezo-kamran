import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_service.dart';
import 'theme_state.dart';
import '../../feature/account/presentation/provider/user_appearance_viewmodel.dart';

/// Theme ViewModel for managing app theme
class ThemeViewModel extends Notifier<ThemeState> {
  late final ThemeService _themeService;

  @override
  ThemeState build() {
    _themeService = ref.read(themeServiceProvider);

    // Listen to user appearance for theme changes
    ref.listen(userAppearanceViewModelProvider, (previous, next) {
      if (next.themeMode != previous?.themeMode) {
        final newMode = AppThemeMode.fromString(next.themeMode);
        if (state.themeMode != newMode) {
          state = state.copyWith(themeMode: newMode);
          _themeService.saveThemeMode(next.themeMode);
        }
      }
    });

    // Load saved theme or use system default
    final savedTheme = _themeService.getThemeMode();
    final themeMode = savedTheme != null
        ? AppThemeMode.fromString(savedTheme)
        : AppThemeMode.system;

    return ThemeState(themeMode: themeMode);
  }

  /// Change theme mode
  Future<void> changeTheme(AppThemeMode newTheme) async {
    state = state.copyWith(isLoading: true);

    try {
      // Save theme preference locally
      await _themeService.saveThemeMode(newTheme.name);

      // Save to user preferences
      await ref
          .read(userAppearanceViewModelProvider.notifier)
          .updateThemeMode(newTheme.name);

      // Update state
      state = state.copyWith(themeMode: newTheme, isLoading: false);
    } catch (e) {
      // Reset loading state on error
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// Reset to system theme
  Future<void> resetToSystemTheme() async {
    await changeTheme(AppThemeMode.system);
  }

  /// Check if using system theme
  bool get isUsingSystemTheme => state.themeMode == AppThemeMode.system;

  /// Check if using light theme
  bool get isUsingLightTheme => state.themeMode == AppThemeMode.light;

  /// Check if using dark theme
  bool get isUsingDarkTheme => state.themeMode == AppThemeMode.dark;
}

// Providers

/// Theme Service Provider
final themeServiceProvider = Provider<ThemeService>((ref) {
  return ThemeService();
});

/// Theme ViewModel Provider
final themeViewModelProvider = NotifierProvider<ThemeViewModel, ThemeState>(() {
  return ThemeViewModel();
});
