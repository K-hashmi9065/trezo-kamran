import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_checker.dart';
import '../../domain/entities/user_appearance.dart';
import '../../domain/repositories/user_appearance_repository.dart';
import '../datasources/user_appearance_local_data_source.dart';
import '../datasources/user_appearance_remote_data_source.dart';
import '../models/user_appearance_model.dart';

class UserAppearanceRepositoryImpl implements UserAppearanceRepository {
  final UserAppearanceRemoteDataSource _remoteDataSource;
  final UserAppearanceLocalDataSource _localDataSource;
  final NetworkChecker _networkChecker;
  final FirebaseAuth _auth;

  UserAppearanceRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkChecker,
    this._auth,
  );

  String? get _currentUserId => _auth.currentUser?.uid;

  @override
  Future<Either<Failure, UserAppearance>> getUserAppearance() async {
    final userId = _currentUserId;
    if (userId == null) {
      return Left(UnauthorizedFailure('User not authenticated'));
    }

    try {
      // 1. Try to get from remote if connected
      if (await _networkChecker.isConnected) {
        try {
          final remoteAppearance = await _remoteDataSource.getUserAppearance(
            userId,
          );
          // Cache locally
          await _localDataSource.saveUserAppearance(userId, remoteAppearance);
          return Right(remoteAppearance);
        } catch (e) {
          // If remote fails, fallback to local
        }
      }

      // 2. Fallback to local
      final localAppearance = await _localDataSource.getUserAppearance(userId);
      if (localAppearance != null) {
        return Right(localAppearance);
      }

      // 3. If no prefs found, return default
      return Right(UserAppearanceModel.initial());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserAppearance>> updateUserAppearance(
    UserAppearance appearance,
  ) async {
    final userId = _currentUserId;
    if (userId == null) {
      return Left(UnauthorizedFailure('User not authenticated'));
    }

    final model = UserAppearanceModel.fromEntity(appearance);

    try {
      // 1. Update local immediately for optimistic UI
      await _localDataSource.saveUserAppearance(userId, model);

      // 2. Sync to remote (Firestore SDK handles offline buffering/syncing)
      try {
        await _remoteDataSource.saveUserAppearance(userId, model);
      } catch (e) {
        // If remote fails immediately (e.g. auth), we still have local
        // But with Firestore SDK, it usually doesn't throw on offline, just queues.
      }

      return Right(model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<UserAppearance> loadInitialAppearance() async {
    // Attempt to load for last user or default
    final localAppearance = await _localDataSource.getLastUserAppearance();
    return localAppearance ?? UserAppearanceModel.initial();
  }
}
