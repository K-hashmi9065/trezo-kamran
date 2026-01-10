import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/network_checker.dart';
import '../../../../core/storage/hive_manager.dart';
import '../datasources/user_profile_local_data_source.dart';
import '../datasources/user_profile_remote_data_source_provider.dart';
import 'user_profile_repository.dart';

/// Provider for UserProfileLocalDataSource
final userProfileLocalDataSourceProvider = Provider<UserProfileLocalDataSource>(
  (ref) {
    // Use a dedicated box for user profile data
    final userBox = HiveManager.userBox;
    return UserProfileLocalDataSource(userBox);
  },
);

/// Provider for UserProfileRepository
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  final remoteDataSource = ref.watch(userProfileRemoteDataSourceProvider);
  final localDataSource = ref.watch(userProfileLocalDataSourceProvider);
  final networkChecker = ref.watch(networkCheckerProvider);

  return UserProfileRepository(
    localDataSource,
    remoteDataSource,
    networkChecker,
  );
});
