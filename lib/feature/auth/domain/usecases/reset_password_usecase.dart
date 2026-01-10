import '../repositories/auth_repository.dart';

/// Use case for password reset
class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<void> call(String email) {
    return _repository.resetPassword(email);
  }
}
