import 'package:logger/logger.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_checker.dart';
import '../datasources/user_profile_local_data_source.dart';
import '../datasources/user_profile_remote_data_source.dart';

/// User profile repository with offline-first strategy
class UserProfileRepository {
  final UserProfileLocalDataSource _localDataSource;
  final UserProfileRemoteDataSource _remoteDataSource;
  final NetworkChecker _networkChecker;
  final Logger _logger = Logger();

  UserProfileRepository(
    this._localDataSource,
    this._remoteDataSource,
    this._networkChecker,
  );

  /// Get user profile - offline-first
  Future<UserModel?> getUserProfile() async {
    // Try remote first if online
    final isConnected = await _networkChecker.isConnected;

    if (isConnected) {
      try {
        _logger.i('Fetching user profile from Firebase');
        final remoteUser = await _remoteDataSource.getUserProfile();

        // Update local cache
        await _localDataSource.cacheUserProfile(remoteUser);

        return remoteUser;
      } on NetworkException catch (e) {
        _logger.w('Network error while fetching profile: $e');
      } on ServerException catch (e) {
        _logger.w('Firebase error while fetching profile: $e');
      } catch (e) {
        _logger.e('Unexpected error while fetching profile: $e');
      }
    }

    // Return from local cache
    _logger.i('Fetching user profile from local cache');
    return await _localDataSource.getCachedUserProfile();
  }

  /// Update user profile
  Future<UserModel> updateUserProfile({
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? gender,
  }) async {
    final isConnected = await _networkChecker.isConnected;

    if (!isConnected) {
      _logger.w('Offline: Cannot update profile without internet');
      throw NoInternetException('Cannot update profile while offline');
    }

    try {
      _logger.i('Updating user profile on Firebase');
      final updatedUser = await _remoteDataSource.updateUserProfile(
        name: name,
        email: email,
        phone: phone,
        photoUrl: photoUrl,
        gender: gender,
      );

      // Update local cache
      await _localDataSource.cacheUserProfile(updatedUser);

      return updatedUser;
    } catch (e) {
      _logger.e('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Upload avatar
  Future<String> uploadAvatar(String filePath) async {
    final isConnected = await _networkChecker.isConnected;

    if (!isConnected) {
      _logger.w('Offline: Cannot upload avatar without internet');
      throw NoInternetException('Cannot upload avatar while offline');
    }

    try {
      _logger.i('Uploading avatar...');
      final avatarUrl = await _remoteDataSource.uploadAvatar(filePath);

      // Update local cache with new avatar URL
      final currentUser = await _localDataSource.getCachedUserProfile();
      if (currentUser != null) {
        final updatedUser = UserModel(
          id: currentUser.id,
          email: currentUser.email,
          displayName: currentUser.displayName,
          photoUrl: avatarUrl,
        );
        await _localDataSource.cacheUserProfile(updatedUser);
      }

      return avatarUrl;
    } catch (e) {
      _logger.e('Error uploading avatar: $e');
      rethrow;
    }
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStats() async {
    final isConnected = await _networkChecker.isConnected;

    if (!isConnected) {
      _logger.w('Offline: Cannot fetch stats without internet');
      return {};
    }

    try {
      _logger.i('Fetching user stats from Firebase');
      return await _remoteDataSource.getUserStats();
    } catch (e) {
      _logger.e('Error fetching user stats: $e');
      return {};
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    final isConnected = await _networkChecker.isConnected;

    if (!isConnected) {
      _logger.w('Offline: Cannot delete account without internet');
      throw NoInternetException('Cannot delete account while offline');
    }

    try {
      _logger.i('Deleting user account on Firebase');
      await _remoteDataSource.deleteAccount();

      // Clear all local data
      await _localDataSource.clearAllUserData();
    } catch (e) {
      _logger.e('Error deleting account: $e');
      rethrow;
    }
  }

  /// Get user preferences - offline-first
  Future<Map<String, dynamic>> getUserPreferences() async {
    // Try remote first if online
    final isConnected = await _networkChecker.isConnected;

    if (isConnected) {
      try {
        _logger.i('Fetching user preferences from Firebase');
        final remotePrefs = await _remoteDataSource.getUserPreferences();

        // Update local cache
        await _localDataSource.saveUserPreferences(remotePrefs);

        return remotePrefs;
      } catch (e) {
        _logger.w('Error fetching remote preferences: $e');
      }
    }

    // Return from local cache
    _logger.i('Fetching user preferences from local cache');
    return await _localDataSource.getUserPreferences();
  }

  /// Update user preferences
  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    // Always save locally first
    _logger.i('Saving user preferences locally');
    await _localDataSource.saveUserPreferences(preferences);

    // Try to sync to remote if online
    final isConnected = await _networkChecker.isConnected;
    if (isConnected) {
      try {
        _logger.i('Syncing preferences to remote API');
        await _remoteDataSource.updateUserPreferences(preferences);
      } catch (e) {
        _logger.w('Failed to sync preferences to remote: $e');
        // Preferences are saved locally, sync can be retried
      }
    } else {
      _logger.w('Offline: Preferences will be synced when online');
    }
  }

  /// Clear cached user profile
  Future<void> clearCache() async {
    await _localDataSource.clearCachedUserProfile();
  }

  /// Clear all user data including cache and preferences
  Future<void> clearAllData() async {
    await _localDataSource.clearAllUserData();
  }
}
