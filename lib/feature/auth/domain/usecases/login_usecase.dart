import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for email/password login
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<User> call(String email, String password) {
    return _repository.loginWithEmail(email, password);
  }
}
