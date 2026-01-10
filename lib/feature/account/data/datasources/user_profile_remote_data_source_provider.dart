import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_providers.dart';
import 'user_profile_remote_data_source.dart';

/// Provider for UserProfileRemoteDataSource
/// Uses file upload Dio instance for avatar uploads
final userProfileRemoteDataSourceProvider =
    Provider<UserProfileRemoteDataSource>((ref) {
      // Use file upload Dio for profile operations (handles avatar uploads)
      final dio = ref.watch(fileUploadDioProvider);
      return UserProfileRemoteDataSource(dio);
    });
