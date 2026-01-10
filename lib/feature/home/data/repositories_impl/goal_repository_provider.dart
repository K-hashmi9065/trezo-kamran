import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../../core/storage/hive_boxes.dart';
import '../../../../core/network/network_checker.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_local_data_source.dart';
import '../datasources/goal_remote_data_source_provider.dart';
import '../models/goal_model.dart';
import 'goal_repository_impl.dart';

/// Provider for GoalRepository with hybrid local+remote support
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  // Get dependencies
  final remoteDataSource = ref.watch(goalRemoteDataSourceProvider);
  final networkChecker = ref.watch(networkCheckerProvider);

  // Get Hive box for local storage
  final goalsBox = Hive.box<GoalModel>(HiveBoxes.goalsBox);
  final localDataSource = GoalLocalDataSource(goalsBox);

  return GoalRepositoryImpl(localDataSource, remoteDataSource, networkChecker);
});
