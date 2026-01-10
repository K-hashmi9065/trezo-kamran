import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../auth/data/models/user_model.dart';

/// Remote data source for user profile operations
class UserProfileRemoteDataSource {
  final Dio _dio;

  UserProfileRemoteDataSource(this._dio);

  /// Get current user profile
  /// Throws [UnauthorizedException], [ServerException], [NetworkException]
  Future<UserModel> getUserProfile() async {
    try {
      final response = await _dio.get(ApiEndpoints.userProfile);

      final data = response.data;
      Map<String, dynamic> userJson;

      if (data is Map && data.containsKey('user')) {
        userJson = data['user'] as Map<String, dynamic>;
      } else if (data is Map) {
        userJson = data as Map<String, dynamic>;
      } else {
        throw ServerException(
          'Invalid response format',
          statusCode: response.statusCode,
        );
      }

      return UserModel.fromJson(userJson);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Update user profile
  /// Returns updated [UserModel]
  Future<UserModel> updateUserProfile({
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (photoUrl != null) 'photoUrl': photoUrl,
      };

      final response = await _dio.put(
        ApiEndpoints.updateUserProfile,
        data: updateData,
      );

      final data = response.data;
      Map<String, dynamic> userJson;

      if (data is Map && data.containsKey('user')) {
        userJson = data['user'] as Map<String, dynamic>;
      } else if (data is Map) {
        userJson = data as Map<String, dynamic>;
      } else {
        throw ServerException(
          'Invalid response format',
          statusCode: response.statusCode,
        );
      }

      return UserModel.fromJson(userJson);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Upload user avatar/profile picture
  /// Returns the new avatar URL
  Future<String> uploadAvatar(String filePath) async {
    try {
      // Create FormData for file upload
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _dio.post(
        ApiEndpoints.uploadAvatar,
        data: formData,
      );

      final data = response.data;

      if (data is Map && data.containsKey('avatarUrl')) {
        return data['avatarUrl'] as String;
      } else if (data is Map && data.containsKey('url')) {
        return data['url'] as String;
      } else if (data is String) {
        return data;
      } else {
        throw ServerException(
          'Invalid response format',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Get user statistics (goals, savings, etc.)
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await _dio.get(ApiEndpoints.userStats);

      final data = response.data;

      if (data is Map && data.containsKey('stats')) {
        return data['stats'] as Map<String, dynamic>;
      } else if (data is Map) {
        return data as Map<String, dynamic>;
      } else {
        throw ServerException(
          'Invalid response format',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Delete user account
  /// This is a destructive operation
  Future<void> deleteAccount() async {
    try {
      await _dio.delete('${ApiEndpoints.userProfile}/delete');
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Update user preferences/settings
  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    try {
      await _dio.put(
        '${ApiEndpoints.userProfile}/preferences',
        data: preferences,
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Get user preferences/settings
  Future<Map<String, dynamic>> getUserPreferences() async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.userProfile}/preferences',
      );

      final data = response.data;

      if (data is Map && data.containsKey('preferences')) {
        return data['preferences'] as Map<String, dynamic>;
      } else if (data is Map) {
        return data as Map<String, dynamic>;
      } else {
        return {};
      }
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Handle Dio errors and convert to custom exceptions
  Never _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw TimeoutException('Request timed out');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] as String?;

        switch (statusCode) {
          case 401:
            throw UnauthorizedException(message ?? 'Unauthorized');
          case 403:
            throw ForbiddenException(message ?? 'Forbidden');
          case 404:
            throw NotFoundException(message ?? 'User not found');
          case 409:
            throw ConflictException(message ?? 'Conflict occurred');
          case 422:
            throw ValidationException(message ?? 'Validation failed');
          default:
            throw ServerException(
              message ?? 'Server error',
              statusCode: statusCode,
            );
        }

      case DioExceptionType.cancel:
        throw NetworkException('Request was cancelled');

      case DioExceptionType.connectionError:
        throw NoInternetException();

      default:
        throw NetworkException(error.message ?? 'Unknown error');
    }
  }
}
