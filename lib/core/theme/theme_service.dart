import 'package:hive_flutter/hive_flutter.dart';

/// Service for persisting theme preferences
class ThemeService {
  static const String _boxName = 'theme_box';
  static const String _themeKey = 'app_theme_mode';

  /// Get the Hive box for theme storage
  Box get _box => Hive.box(_boxName);

  /// Initialize the theme service
  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  /// Save theme mode
  Future<void> saveThemeMode(String themeMode) async {
    await _box.put(_themeKey, themeMode);
  }

  /// Get saved theme mode
  String? getThemeMode() {
    return _box.get(_themeKey) as String?;
  }

  /// Check if theme mode is saved
  bool hasThemeMode() {
    return _box.containsKey(_themeKey);
  }

  /// Clear theme preference
  Future<void> clearThemeMode() async {
    await _box.delete(_themeKey);
  }
}
