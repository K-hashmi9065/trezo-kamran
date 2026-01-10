import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/auth_service.dart';
import '../models/user_model.dart';

/// Remote data source for authentication operations
class AuthRemoteDataSource {
  final AuthService _authService;

  AuthRemoteDataSource(this._authService);

  /// Sign up with email and password
  Future<UserModel> signUpWithEmail(String email, String password) async {
    final user = await _authService.signUpWithEmailAndPassword(email, password);
    if (user == null) {
      throw Exception('Sign up failed: No user returned');
    }
    return UserModel.fromFirebase(user);
  }

  /// Login with email and password
  Future<UserModel> loginWithEmail(String email, String password) async {
    final user = await _authService.loginWithEmailAndPassword(email, password);
    if (user == null) {
      throw Exception('Login failed: No user returned');
    }
    return UserModel.fromFirebase(user);
  }

  /// Login with Google
  Future<UserModel?> loginWithGoogle() async {
    final user = await _authService.signInWithGoogle();
    if (user == null) return null;
    return UserModel.fromFirebase(user);
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Password reset failed');
    }
  }

  /// Sign out
  Future<void> logout() async {
    await _authService.signOut();
  }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return UserModel.fromFirebase(user);
  }
}
