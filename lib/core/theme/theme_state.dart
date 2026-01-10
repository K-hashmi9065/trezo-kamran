import 'package:flutter/material.dart';

/// Theme state options
enum AppThemeMode {
  system,
  light,
  dark;

  /// Convert to Flutter's ThemeMode
  ThemeMode toThemeMode() {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  /// Get display name for the theme mode
  String get displayName {
    switch (this) {
      case AppThemeMode.system:
        return 'System Default';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }

  /// Create from string
  static AppThemeMode fromString(String value) {
    switch (value.toLowerCase()) {
      case 'system':
        return AppThemeMode.system;
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      default:
        return AppThemeMode.system;
    }
  }
}

/// State class for theme
class ThemeState {
  final AppThemeMode themeMode;
  final bool isLoading;

  const ThemeState({required this.themeMode, this.isLoading = false});

  ThemeState copyWith({AppThemeMode? themeMode, bool? isLoading}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
