import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/app_snack_bar.dart';
import '../../../../core/router/route_names.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';
import '../../domain/usecases/google_signin_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../../../feature/home/data/repositories_impl/goal_repository_provider.dart';
import 'auth_state.dart';

/// Auth ViewModel managing authentication state
class AuthViewModel extends Notifier<AuthState> {
  late final LoginUseCase _loginUseCase;
  late final SignUpUseCase _signUpUseCase;
  late final GoogleSignInUseCase _googleSignInUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final ResetPasswordUseCase _resetPasswordUseCase;

  @override
  AuthState build() {
    // Initialize use cases
    final repository = ref.read(authRepositoryProvider);
    _loginUseCase = LoginUseCase(repository);
    _signUpUseCase = SignUpUseCase(repository);
    _googleSignInUseCase = GoogleSignInUseCase(repository);
    _logoutUseCase = LogoutUseCase(repository);
    _resetPasswordUseCase = ResetPasswordUseCase(repository);

    return const AuthInitial();
  }

  /// Login with email and password
  Future<void> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    state = const AuthLoading();
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final user = await _loginUseCase(email, password);
      state = AuthSuccess(user, message: 'Welcome back ${user.email}');

      // Close loading dialog
      if (context.mounted) context.pop();

      // Show success toast
      if (context.mounted) {
        AppSnackBar.showSuccess(
          context,
          message: 'Welcome back ${user.email}',
          title: "Login Successful",
        );

        // Navigate based on goals
        await _checkGoalsAndNavigate(context);
      }
    } catch (e) {
      state = AuthError(e.toString());

      // Close loading dialog
      if (context.mounted && Navigator.of(context).canPop()) {
        context.pop();
      }

      // Show error toast
      if (context.mounted) {
        AppSnackBar.showError(
          context,
          message: e.toString(),
          title: "Login Failed",
        );
      }
    }
  }

  /// Sign up with email and password
  Future<void> signUp(
    BuildContext context,
    String email,
    String password,
  ) async {
    state = const AuthLoading();
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final user = await _signUpUseCase(email, password);
      state = AuthSuccess(user, message: 'Welcome ${user.email}');

      // Close loading dialog
      if (context.mounted) context.pop();

      // Show success toast
      if (context.mounted) {
        AppSnackBar.showSuccess(
          context,
          message: 'Welcome ${user.email}',
          title: "Sign Up Successful",
        );

        // Navigate to home screen
        context.go(RouteNames.emptyHomeScreen);
      }
    } catch (e) {
      state = AuthError(e.toString());

      // Close loading dialog
      if (context.mounted && Navigator.of(context).canPop()) {
        context.pop();
      }

      // Show error toast
      if (context.mounted) {
        AppSnackBar.showError(
          context,
          message: e.toString(),
          title: "Sign Up Failed",
        );
      }
    }
  }

  /// Sign in with Google
  Future<void> googleSignIn(BuildContext context) async {
    state = const AuthLoading();

    try {
      final user = await _googleSignInUseCase();
      if (user != null) {
        state = AuthSuccess(user, message: 'Welcome back ${user.email}');

        // Show success toast
        if (context.mounted) {
          AppSnackBar.showSuccess(
            context,
            message: 'Welcome back ${user.email}',
            title: "Sign In Successful",
          );

          // Navigate based on goals
          await _checkGoalsAndNavigate(context);
        }
      } else {
        state = const AuthError('Google sign-in was cancelled');

        // Show info toast for cancelled action
        if (context.mounted) {
          AppSnackBar.showInfo(
            context,
            message: 'Google sign-in was cancelled',
            title: "Cancelled",
          );
        }
      }
    } catch (e) {
      state = AuthError('Google sign-in failed: $e');

      // Show error toast
      if (context.mounted) {
        AppSnackBar.showError(
          context,
          message: 'Google sign-in failed: $e',
          title: "Sign In Failed",
        );
      }
    }
  }

  /// Reset password
  Future<void> resetPassword(BuildContext context, String email) async {
    state = const AuthLoading();
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _resetPasswordUseCase(email);
      state = const AuthInitial();

      // Close loading dialog
      if (context.mounted) context.pop();

      // Show success toast
      if (context.mounted) {
        AppSnackBar.showSuccess(
          context,
          message: 'Password reset email sent! Check your inbox.',
          title: "Email Sent",
          duration: Duration(seconds: 4),
        );

        // Navigate back
        context.pop();
      }
    } catch (e) {
      state = AuthError(e.toString());

      // Close loading dialog
      if (context.mounted && Navigator.of(context).canPop()) {
        context.pop();
      }

      // Show error toast
      if (context.mounted) {
        AppSnackBar.showError(
          context,
          message: e.toString(),
          title: "Password Reset Failed",
        );
      }
    }
  }

  /// Logout
  Future<void> logout() async {
    state = const AuthLoading();
    try {
      await _logoutUseCase();
      state = const AuthLoggedOut();
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  /// Reset to initial state
  void resetState() {
    state = const AuthInitial();
  }

  /// Check for existing goals and navigate accordingly
  Future<void> _checkGoalsAndNavigate(BuildContext context) async {
    if (!context.mounted) return;

    try {
      final goalRepository = ref.read(goalRepositoryProvider);
      final hasGoals = await goalRepository.hasAnyGoals();

      if (context.mounted) {
        if (hasGoals) {
          context.go(RouteNames.homeScreen);
        } else {
          context.go(RouteNames.emptyHomeScreen);
        }
      }
    } catch (e) {
      // Fallback to empty home screen on error
      if (context.mounted) {
        context.go(RouteNames.emptyHomeScreen);
      }
    }
  }
}

// Providers

/// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Auth Remote Data Source Provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthRemoteDataSource(authService);
});

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource);
});

/// Auth ViewModel Provider
final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(() {
  return AuthViewModel();
});
