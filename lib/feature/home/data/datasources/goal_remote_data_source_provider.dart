import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_providers.dart';
import 'goal_remote_data_source.dart';

/// Provider for GoalRemoteDataSource
/// Injects authenticated Dio instance
final goalRemoteDataSourceProvider = Provider<GoalRemoteDataSource>((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return GoalRemoteDataSource(dio);
});
