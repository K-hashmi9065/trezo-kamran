import '../entities/user.dart';

/// Abstract repository defining auth operations
abstract class AuthRepository {
  /// Sign up with email and password
  Future<User> signUpWithEmail(String email, String password);

  /// Login with email and password
  Future<User> loginWithEmail(String email, String password);

  /// Login with Google OAuth
  Future<User?> loginWithGoogle();

  /// Send password reset email
  Future<void> resetPassword(String email);

  /// Sign out current user
  Future<void> logout();

  /// Get current authenticated user
  Future<User?> getCurrentUser();
}
