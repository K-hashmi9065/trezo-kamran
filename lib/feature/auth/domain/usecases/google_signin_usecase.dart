import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for Google OAuth login
class GoogleSignInUseCase {
  final AuthRepository _repository;

  GoogleSignInUseCase(this._repository);

  Future<User?> call() {
    return _repository.loginWithGoogle();
  }
}
