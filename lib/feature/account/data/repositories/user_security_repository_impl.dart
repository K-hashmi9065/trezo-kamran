import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_checker.dart';
import '../../domain/entities/user_security.dart';
import '../../domain/repositories/user_security_repository.dart';
import '../datasources/user_security_local_data_source.dart';
import '../datasources/user_security_remote_data_source.dart';
import '../models/user_security_model.dart';

class UserSecurityRepositoryImpl implements UserSecurityRepository {
  final UserSecurityRemoteDataSource _remoteDataSource;
  final UserSecurityLocalDataSource _localDataSource;
  final NetworkChecker _networkChecker;
  final FirebaseAuth _auth;

  UserSecurityRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkChecker,
    this._auth,
  );

  String? get _currentUserId => _auth.currentUser?.uid;

  @override
  Future<Either<Failure, UserSecurity>> getUserSecurity() async {
    final userId = _currentUserId;
    if (userId == null) {
      return Left(UnauthorizedFailure('User not authenticated'));
    }

    try {
      if (await _networkChecker.isConnected) {
        try {
          final remoteSecurity = await _remoteDataSource.getUserSecurity(
            userId,
          );
          await _localDataSource.saveUserSecurity(userId, remoteSecurity);
          return Right(remoteSecurity);
        } catch (e) {
          // Fallback to local on remote error (if not crit)
        }
      }

      final localSecurity = await _localDataSource.getUserSecurity(userId);
      if (localSecurity != null) {
        return Right(localSecurity);
      }

      return Right(UserSecurityModel.initial());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserSecurity>> updateUserSecurity(
    UserSecurity security,
  ) async {
    final userId = _currentUserId;
    if (userId == null) {
      return Left(UnauthorizedFailure('User not authenticated'));
    }

    final model = UserSecurityModel.fromEntity(security);

    try {
      await _localDataSource.saveUserSecurity(userId, model);

      try {
        await _remoteDataSource.saveUserSecurity(userId, model);
      } catch (e) {
        // Queue/ignore if offline
      }

      return Right(model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<UserSecurity> loadInitialSecurity() async {
    final localSecurity = await _localDataSource.getLastUserSecurity();
    return localSecurity ?? UserSecurityModel.initial();
  }
}
