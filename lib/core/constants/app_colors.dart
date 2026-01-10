import 'package:flutter/material.dart';

class AppColors {
  // Primary (DO NOT CHANGE)
  static const primaryBlue = Color(0xFF625DFA);

  // Secondary / Background (DO NOT CHANGE)
  static const lightBlue = Color(0xFFF2F1FD);

  // Light Theme Colors
  static const _lightWhite = Color(0xFFFFFFFF);
  static const _lightBackground = Color(0xFFF1F1F1);
  static const _lightBorder = Color(0xFFF3F3F3);
  static const _lightBox = Color(0xFFFAFAFA);
  static const _lightTextPrimary = Color(0xFF111827);
  static const _lightTextSecondary = Color(0xFF6B7280);
  static const _lightTextDisabled = Color(0xFF9CA3AF);

  // Dark Theme Colors
  static const _darkWhite = Color(0xFF1E1E1E);
  static const _darkBackground = Color(0xFF121212);
  static const _darkBorder = Color(0xFF2A2A2A);
  static const _darkBox = Color(0xFF1E1E1E);
  static const _darkTextPrimary = Color(0xFFFFFFFF);
  static const _darkTextSecondary = Color(0xFFB0B0B0);
  static const _darkTextDisabled = Color(0xFF6B6B6B);

  // Status Colors (Same for both themes)
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);

  // Static versions for backwards compatibility (use light theme colors)
  // These are kept for existing code that doesn't have BuildContext
  static const white = _lightWhite;
  static const background = _lightBackground;
  static const border = _lightBorder;
  static const box = _lightBox;
  static const textPrimary = _lightTextPrimary;
  static const textSecondary = _lightTextSecondary;
  static const textDisabled = _lightTextDisabled;
}

/// Extension on BuildContext to get theme-aware colors
extension AppColorsExtension on BuildContext {
  Color get backgroundClr {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColors._darkBackground
        : AppColors._lightBackground;
  }

  Color get whiteClr {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColors._darkWhite
        : AppColors._lightWhite;
  }

  Color get borderClr {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColors._darkBorder
        : AppColors._lightBorder;
  }

  Color get boxClr {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColors._darkBox
        : AppColors._lightBox;
  }

  Color get textPrimaryClr {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColors._darkTextPrimary
        : AppColors._lightTextPrimary;
  }

  Color get textSecondaryClr {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColors._darkTextSecondary
        : AppColors._lightTextSecondary;
  }

  Color get textDisabledClr {
    return Theme.of(this).brightness == Brightness.dark
        ? AppColors._darkTextDisabled
        : AppColors._lightTextDisabled;
  }
}
