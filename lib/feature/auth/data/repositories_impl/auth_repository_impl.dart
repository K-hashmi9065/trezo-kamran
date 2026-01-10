import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<User> signUpWithEmail(String email, String password) async {
    final userModel = await _remoteDataSource.signUpWithEmail(email, password);
    return userModel.toEntity();
  }

  @override
  Future<User> loginWithEmail(String email, String password) async {
    final userModel = await _remoteDataSource.loginWithEmail(email, password);
    return userModel.toEntity();
  }

  @override
  Future<User?> loginWithGoogle() async {
    final userModel = await _remoteDataSource.loginWithGoogle();
    return userModel?.toEntity();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _remoteDataSource.resetPassword(email);
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
  }

  @override
  Future<User?> getCurrentUser() async {
    final userModel = await _remoteDataSource.getCurrentUser();
    return userModel?.toEntity();
  }
}
