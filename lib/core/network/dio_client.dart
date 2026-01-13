// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'api_endpoints.dart';
// import 'dio_interceptors.dart';

// /// Centralized Dio client configuration and factory
// class DioClient {
//   // Private constructor to prevent direct instantiation
//   DioClient._();

//   /// Timeout durations
//   static const Duration connectTimeout = Duration(seconds: 30);
//   static const Duration receiveTimeout = Duration(seconds: 30);
//   static const Duration sendTimeout = Duration(seconds: 30);

//   /// Create a basic Dio instance without authentication
//   /// Useful for public endpoints that don't require auth
//   static Dio createPublicDio() {
//     final dio = Dio(
//       BaseOptions(
//         baseUrl: ApiEndpoints.apiBaseUrl,
//         connectTimeout: connectTimeout,
//         receiveTimeout: receiveTimeout,
//         sendTimeout: sendTimeout,
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         validateStatus: (status) {
//           // Consider all responses as successful for error interceptor to handle
//           return status != null && status < 500;
//         },
//       ),
//     );

//     // Add interceptors
//     if (kDebugMode) {
//       // Only add logging in debug mode
//       dio.interceptors.add(LoggingInterceptor());
//     }

//     dio.interceptors.add(ErrorInterceptor());
//     dio.interceptors.add(RetryInterceptor(maxRetries: 3));

//     return dio;
//   }

//   /// Create an authenticated Dio instance
//   /// Automatically injects Firebase ID token in request headers
//   static Dio createAuthenticatedDio() {
//     final dio = Dio(
//       BaseOptions(
//         baseUrl: ApiEndpoints.apiBaseUrl,
//         connectTimeout: connectTimeout,
//         receiveTimeout: receiveTimeout,
//         sendTimeout: sendTimeout,
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         validateStatus: (status) {
//           // Consider all responses as successful for error interceptor to handle
//           return status != null && status < 500;
//         },
//       ),
//     );

//     // Order matters! Auth should be first to inject token
//     dio.interceptors.add(AuthInterceptor());

//     if (kDebugMode) {
//       // Only add logging in debug mode
//       dio.interceptors.add(LoggingInterceptor());
//     }

//     dio.interceptors.add(ErrorInterceptor());
//     dio.interceptors.add(RetryInterceptor(maxRetries: 3));

//     return dio;
//   }

//   /// Create a Dio instance with custom configuration
//   /// Useful for special cases like file uploads, downloads, etc.
//   static Dio createCustomDio({
//     String? baseUrl,
//     Duration? connectTimeout,
//     Duration? receiveTimeout,
//     Duration? sendTimeout,
//     Map<String, dynamic>? headers,
//     bool requiresAuth = true,
//     bool enableLogging = kDebugMode,
//     int maxRetries = 3,
//   }) {
//     final dio = Dio(
//       BaseOptions(
//         baseUrl: baseUrl ?? ApiEndpoints.apiBaseUrl,
//         connectTimeout: connectTimeout ?? DioClient.connectTimeout,
//         receiveTimeout: receiveTimeout ?? DioClient.receiveTimeout,
//         sendTimeout: sendTimeout ?? DioClient.sendTimeout,
//         headers:
//             headers ??
//             {'Content-Type': 'application/json', 'Accept': 'application/json'},
//         validateStatus: (status) {
//           return status != null && status < 500;
//         },
//       ),
//     );

//     // Add interceptors based on configuration
//     if (requiresAuth) {
//       dio.interceptors.add(AuthInterceptor());
//     }

//     if (enableLogging) {
//       dio.interceptors.add(LoggingInterceptor());
//     }

//     dio.interceptors.add(ErrorInterceptor());

//     if (maxRetries > 0) {
//       dio.interceptors.add(RetryInterceptor(maxRetries: maxRetries));
//     }

//     return dio;
//   }

//   /// Create a Dio instance for file uploads
//   /// - Longer timeouts for large files
//   /// - FormData content type
//   static Dio createFileUploadDio({bool requiresAuth = true}) {
//     return createCustomDio(
//       connectTimeout: const Duration(minutes: 5),
//       receiveTimeout: const Duration(minutes: 5),
//       sendTimeout: const Duration(minutes: 5),
//       headers: {
//         'Accept': 'application/json',
//         // Content-Type will be set automatically by FormData
//       },
//       requiresAuth: requiresAuth,
//       maxRetries: 2, // Fewer retries for large uploads
//     );
//   }

//   /// Create a Dio instance for file downloads
//   /// - Longer receive timeout
//   /// - Stream response type
//   static Dio createFileDownloadDio({bool requiresAuth = true}) {
//     final dio = createCustomDio(
//       connectTimeout: const Duration(minutes: 2),
//       receiveTimeout: const Duration(minutes: 10),
//       sendTimeout: const Duration(seconds: 30),
//       requiresAuth: requiresAuth,
//       maxRetries: 2,
//     );

//     // Set response type to stream for downloads
//     dio.options.responseType = ResponseType.stream;

//     return dio;
//   }

//   /// Cancel all pending requests
//   /// Useful when user logs out or navigates away
//   static void cancelAllRequests(Dio dio, {String? reason}) {
//     dio.close(force: true);
//   }
// }
