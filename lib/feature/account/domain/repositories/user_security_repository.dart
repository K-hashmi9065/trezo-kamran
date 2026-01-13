import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_security.dart';

abstract class UserSecurityRepository {
  Future<Either<Failure, UserSecurity>> getUserSecurity();
  Future<Either<Failure, UserSecurity>> updateUserSecurity(
    UserSecurity security,
  );
  Future<UserSecurity> loadInitialSecurity();
}
