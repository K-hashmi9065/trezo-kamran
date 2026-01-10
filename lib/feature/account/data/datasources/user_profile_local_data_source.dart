import 'package:hive/hive.dart';
import '../../../auth/data/models/user_model.dart';

/// Local data source for user profile operations using Hive
class UserProfileLocalDataSource {
  final Box<Map<dynamic, dynamic>> _userBox;
  static const String _userKey = 'current_user';
  static const String _preferencesKey = 'user_preferences';

  UserProfileLocalDataSource(this._userBox);

  /// Get cached user profile
  Future<UserModel?> getCachedUserProfile() async {
    try {
      final userData = _userBox.get(_userKey);
      if (userData == null) return null;

      return UserModel.fromJson(Map<String, dynamic>.from(userData));
    } catch (e) {
      throw Exception('Failed to get cached user profile: $e');
    }
  }

  /// Cache user profile
  Future<void> cacheUserProfile(UserModel user) async {
    try {
      await _userBox.put(_userKey, user.toJson());
    } catch (e) {
      throw Exception('Failed to cache user profile: $e');
    }
  }

  /// Clear cached user profile
  Future<void> clearCachedUserProfile() async {
    try {
      await _userBox.delete(_userKey);
    } catch (e) {
      throw Exception('Failed to clear cached user profile: $e');
    }
  }

  /// Get user preferences
  Future<Map<String, dynamic>> getUserPreferences() async {
    try {
      final prefs = _userBox.get(_preferencesKey);
      if (prefs == null) return {};

      return Map<String, dynamic>.from(prefs);
    } catch (e) {
      throw Exception('Failed to get user preferences: $e');
    }
  }

  /// Save user preferences
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    try {
      await _userBox.put(_preferencesKey, preferences);
    } catch (e) {
      throw Exception('Failed to save user preferences: $e');
    }
  }

  /// Clear user preferences
  Future<void> clearUserPreferences() async {
    try {
      await _userBox.delete(_preferencesKey);
    } catch (e) {
      throw Exception('Failed to clear user preferences: $e');
    }
  }

  /// Clear all user data
  Future<void> clearAllUserData() async {
    try {
      await _userBox.clear();
    } catch (e) {
      throw Exception('Failed to clear all user data: $e');
    }
  }
}
