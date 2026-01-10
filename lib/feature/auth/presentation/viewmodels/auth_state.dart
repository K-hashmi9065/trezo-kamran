import '../../domain/entities/user.dart';

/// Base class for auth states
sealed class AuthState {
  const AuthState();
}

/// Initial state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Success state with user data
class AuthSuccess extends AuthState {
  final User user;
  final String? message;

  const AuthSuccess(this.user, {this.message});
}

/// Error state
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);
}

/// Logged out state
class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}
