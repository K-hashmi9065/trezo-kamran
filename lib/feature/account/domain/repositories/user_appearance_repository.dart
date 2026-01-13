import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_appearance.dart';

abstract class UserAppearanceRepository {
  /// Get appearance settings for the current user
  Future<Either<Failure, UserAppearance>> getUserAppearance();

  /// Update appearance settings for the current user
  Future<Either<Failure, UserAppearance>> updateUserAppearance(
    UserAppearance appearance,
  );

  /// Load initial appearance (e.g. from local storage for quick start)
  Future<UserAppearance> loadInitialAppearance();
}
