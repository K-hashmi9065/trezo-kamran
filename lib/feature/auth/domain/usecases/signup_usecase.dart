import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for user registration
class SignUpUseCase {
  final AuthRepository _repository;

  SignUpUseCase(this._repository);

  Future<User> call(String email, String password) {
    return _repository.signUpWithEmail(email, password);
  }
}
