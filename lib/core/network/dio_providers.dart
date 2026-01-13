// import 'package:dio/dio.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'dio_client.dart';

// /// Riverpod providers for Dio instances
// /// These can be injected into repositories and data sources

// /// Provider for public Dio instance (no authentication required)
// /// Use for public endpoints like login, register, etc.
// final publicDioProvider = Provider<Dio>((ref) {
//   return DioClient.createPublicDio();
// });

// /// Provider for authenticated Dio instance
// /// Automatically injects Firebase ID token in headers
// /// Use for protected endpoints that require authentication
// final authenticatedDioProvider = Provider<Dio>((ref) {
//   return DioClient.createAuthenticatedDio();
// });

// /// Provider for file upload Dio instance
// /// Has longer timeouts suitable for large file uploads
// final fileUploadDioProvider = Provider<Dio>((ref) {
//   return DioClient.createFileUploadDio();
// });

// /// Provider for file download Dio instance
// /// Has longer timeouts and stream response type
// final fileDownloadDioProvider = Provider<Dio>((ref) {
//   return DioClient.createFileDownloadDio();
// });

// /// Provider for Dio instance with custom configuration
// /// Example usage in a repository:
// /// ```dart
// /// final customDio = ref.read(customDioProvider({
// ///   'baseUrl': 'https://custom-api.com',
// ///   'requiresAuth': true,
// /// }));
// /// ```
// final customDioProvider = Provider.family<Dio, Map<String, dynamic>>((
//   ref,
//   config,
// ) {
//   return DioClient.createCustomDio(
//     baseUrl: config['baseUrl'] as String?,
//     connectTimeout: config['connectTimeout'] as Duration?,
//     receiveTimeout: config['receiveTimeout'] as Duration?,
//     sendTimeout: config['sendTimeout'] as Duration?,
//     headers: config['headers'] as Map<String, dynamic>?,
//     requiresAuth: config['requiresAuth'] as bool? ?? true,
//     enableLogging: config['enableLogging'] as bool? ?? true,
//     maxRetries: config['maxRetries'] as int? ?? 3,
//   );
// });
