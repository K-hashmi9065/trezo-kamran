import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../data/repositories/user_profile_repository_provider.dart';

/// User profile state
sealed class UserProfileState {
  const UserProfileState();
}

class UserProfileInitial extends UserProfileState {
  const UserProfileInitial();
}

class UserProfileLoading extends UserProfileState {
  const UserProfileLoading();
}

class UserProfileLoaded extends UserProfileState {
  final UserModel user;
  const UserProfileLoaded(this.user);
}

class UserProfileError extends UserProfileState {
  final String message;
  const UserProfileError(this.message);
}

class UserProfileSuccess extends UserProfileLoaded {
  final String message;
  const UserProfileSuccess(super.user, this.message);
}

/// User profile ViewModel
class UserProfileViewModel extends Notifier<UserProfileState> {
  @override
  UserProfileState build() {
    loadUserProfile();
    return const UserProfileInitial();
  }

  /// Load user profile
  Future<void> loadUserProfile() async {
    state = const UserProfileLoading();
    try {
      final repository = ref.read(userProfileRepositoryProvider);
      final user = await repository.getUserProfile();

      if (user != null) {
        state = UserProfileLoaded(user);
      } else {
        state = const UserProfileError('No user profile found');
      }
    } on NoInternetException catch (e) {
      state = UserProfileError(e.message);
    } catch (e) {
      state = UserProfileError('Failed to load profile: $e');
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? gender,
  }) async {
    state = const UserProfileLoading();
    try {
      final repository = ref.read(userProfileRepositoryProvider);
      final updatedUser = await repository.updateUserProfile(
        name: name,
        email: email,
        phone: phone,
        gender: gender,
      );

      state = UserProfileLoaded(updatedUser);
      // Show success message temporarily
      Future.delayed(const Duration(seconds: 2), () {
        if (state is! UserProfileLoaded) return;
        state = UserProfileSuccess(
          updatedUser,
          'Profile updated successfully!',
        );
      });
    } on NoInternetException {
      state = const UserProfileError('Cannot update profile while offline');
    } catch (e) {
      state = UserProfileError('Failed to update profile: $e');
    }
  }

  /// Upload avatar
  Future<void> uploadAvatar(String imagePath) async {
    try {
      final repository = ref.read(userProfileRepositoryProvider);
      await repository.uploadAvatar(imagePath);

      // Reload profile to get updated avatar
      await loadUserProfile();

      if (state is UserProfileLoaded) {
        final currentUser = (state as UserProfileLoaded).user;
        state = UserProfileSuccess(
          currentUser,
          'Avatar uploaded successfully!',
        );
        Future.delayed(const Duration(seconds: 2), loadUserProfile);
      }
    } on NoInternetException {
      state = const UserProfileError('Cannot upload avatar while offline');
    } catch (e) {
      state = UserProfileError('Failed to upload avatar: $e');
    }
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final repository = ref.read(userProfileRepositoryProvider);
      return await repository.getUserStats();
    } catch (e) {
      return {};
    }
  }

  /// Refresh profile
  Future<void> refresh() async {
    await loadUserProfile();
  }
}

/// User profile ViewModel provider
final userProfileViewModelProvider =
    NotifierProvider<UserProfileViewModel, UserProfileState>(() {
      return UserProfileViewModel();
    });
