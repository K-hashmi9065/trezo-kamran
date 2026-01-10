import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import '../error/exceptions.dart';

/// Custom Dio interceptors for authentication, logging, error handling, and retry logic

// ============================================================================
// Auth Interceptor - Automatically inject authentication tokens
// ============================================================================

class AuthInterceptor extends Interceptor {
  final Logger _logger = Logger();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Get current Firebase user
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Get Firebase ID token
        final idToken = await user.getIdToken();

        if (idToken != null) {
          // Add token to Authorization header
          options.headers['Authorization'] = 'Bearer $idToken';
          _logger.d('Auth token added to request: ${options.uri}');
        }
      } else {
        _logger.w('No authenticated user found for request: ${options.uri}');
      }

      handler.next(options);
    } catch (e) {
      _logger.e('Error adding auth token: $e');
      handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // If we get 401, try refreshing the token
    if (err.response?.statusCode == 401) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Force refresh the token
          await user.getIdToken(true);
          _logger.d('Token refreshed, retrying request');

          // Retry the request
          final options = err.requestOptions;
          final idToken = await user.getIdToken();
          options.headers['Authorization'] = 'Bearer $idToken';

          try {
            final response = await Dio().fetch(options);
            handler.resolve(response);
            return;
          } catch (e) {
            _logger.e('Retry after token refresh failed: $e');
          }
        }
      } catch (e) {
        _logger.e('Error refreshing token: $e');
      }
    }

    handler.next(err);
  }
}

// ============================================================================
// Logging Interceptor - Pretty print requests and responses in debug mode
// ============================================================================

class LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 75,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.i('''
╔════════════════════════════════════════════════════════════════
║ 🚀 REQUEST
╠════════════════════════════════════════════════════════════════
║ Method: ${options.method}
║ URL: ${options.uri}
║ Headers: ${_formatHeaders(options.headers)}
║ Query Params: ${options.queryParameters}
║ Body: ${options.data}
╚════════════════════════════════════════════════════════════════
''');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i('''
╔════════════════════════════════════════════════════════════════
║ ✅ RESPONSE
╠════════════════════════════════════════════════════════════════
║ Status Code: ${response.statusCode}
║ URL: ${response.requestOptions.uri}
║ Data: ${_formatData(response.data)}
╚════════════════════════════════════════════════════════════════
''');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('''
╔════════════════════════════════════════════════════════════════
║ ❌ ERROR
╠════════════════════════════════════════════════════════════════
║ Status Code: ${err.response?.statusCode}
║ URL: ${err.requestOptions.uri}
║ Type: ${err.type}
║ Message: ${err.message}
║ Response: ${err.response?.data}
╚════════════════════════════════════════════════════════════════
''');
    handler.next(err);
  }

  String _formatHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);
    // Hide sensitive headers
    if (sanitized.containsKey('Authorization')) {
      sanitized['Authorization'] = '***HIDDEN***';
    }
    return sanitized.toString();
  }

  String _formatData(dynamic data) {
    if (data == null) return 'null';
    if (data is String && data.length > 500) {
      return '${data.substring(0, 500)}... (truncated)';
    }
    return data.toString();
  }
}

// ============================================================================
// Error Interceptor - Convert Dio errors to custom exceptions
// ============================================================================

class ErrorInterceptor extends Interceptor {
  final Logger _logger = Logger();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Exception exception;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        exception = TimeoutException('Request timed out');
        break;

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final message = _extractErrorMessage(err.response?.data);

        switch (statusCode) {
          case 400:
            exception = BadRequestException(
              message ?? 'Bad request',
              errors: err.response?.data is Map
                  ? Map<String, dynamic>.from(err.response!.data)
                  : null,
            );
            break;
          case 401:
            exception = UnauthorizedException(message ?? 'Unauthorized access');
            break;
          case 403:
            exception = ForbiddenException(message ?? 'Access forbidden');
            break;
          case 404:
            exception = NotFoundException(message ?? 'Resource not found');
            break;
          case 409:
            exception = ConflictException(
              message ?? 'Conflict occurred',
              conflictData: err.response?.data,
            );
            break;
          case 422:
            exception = ValidationException(
              message ?? 'Validation failed',
              fieldErrors: _extractFieldErrors(err.response?.data),
            );
            break;
          case 429:
            exception = TooManyRequestsException(
              message ?? 'Too many requests',
            );
            break;
          case 500:
          case 502:
          case 503:
            exception = ServerException(
              message ?? 'Server error',
              statusCode: statusCode,
              data: err.response?.data,
            );
            break;
          default:
            exception = ServerException(
              message ?? 'Unknown server error',
              statusCode: statusCode,
              data: err.response?.data,
            );
        }
        break;

      case DioExceptionType.cancel:
        exception = NetworkException('Request was cancelled');
        break;

      case DioExceptionType.connectionError:
        exception = NoInternetException('No internet connection');
        break;

      case DioExceptionType.badCertificate:
        exception = NetworkException('SSL certificate error');
        break;

      case DioExceptionType.unknown:
        exception = NetworkException(
          err.message ?? 'Unknown error occurred',
          details: err.error?.toString(),
        );
    }

    _logger.e('Dio error converted to: ${exception.runtimeType}');

    // Reject with the original error but attach our custom exception
    // This allows the error to be caught as the custom exception type
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        type: err.type,
        response: err.response,
      ),
    );
  }

  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      // Try common error message fields
      return data['message'] as String? ??
          data['error'] as String? ??
          data['msg'] as String? ??
          data['detail'] as String?;
    }

    if (data is String) {
      return data;
    }

    return null;
  }

  Map<String, List<String>>? _extractFieldErrors(dynamic data) {
    if (data == null || data is! Map) return null;

    try {
      final errors = <String, List<String>>{};

      // Try to extract validation errors
      if (data.containsKey('errors') && data['errors'] is Map) {
        final errorMap = data['errors'] as Map;
        errorMap.forEach((key, value) {
          if (value is List) {
            errors[key.toString()] = value.map((e) => e.toString()).toList();
          } else {
            errors[key.toString()] = [value.toString()];
          }
        });
        return errors;
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}

// ============================================================================
// Retry Interceptor - Implements retry logic with exponential backoff
// ============================================================================

class RetryInterceptor extends Interceptor {
  final Logger _logger = Logger();
  final int maxRetries;
  final Duration initialDelay;

  RetryInterceptor({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = err.requestOptions;

    // Don't retry these cases
    if (!_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    // Check if we've already retried too many times
    final retries = requestOptions.extra['retries'] as int? ?? 0;

    if (retries >= maxRetries) {
      _logger.w('Max retries ($maxRetries) reached for ${requestOptions.uri}');
      handler.next(err);
      return;
    }

    // Calculate delay with exponential backoff
    final delay = initialDelay * (retries + 1);
    _logger.i(
      'Retrying request (${retries + 1}/$maxRetries) after ${delay.inSeconds}s: ${requestOptions.uri}',
    );

    // Wait before retrying
    await Future.delayed(delay);

    // Update retry count
    requestOptions.extra['retries'] = retries + 1;

    // Retry the request
    try {
      final dio = Dio();
      final response = await dio.request(
        requestOptions.uri.toString(),
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: Options(
          method: requestOptions.method,
          headers: requestOptions.headers,
          sendTimeout: requestOptions.sendTimeout,
          receiveTimeout: requestOptions.receiveTimeout,
        ),
      );
      handler.resolve(response);
    } catch (e) {
      if (e is DioException) {
        handler.next(e);
      } else {
        handler.next(err);
      }
    }
  }

  bool _shouldRetry(DioException err) {
    // Only retry on certain error types
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;

      case DioExceptionType.badResponse:
        // Retry on server errors (5xx) and rate limiting (429)
        final statusCode = err.response?.statusCode;
        return statusCode != null && (statusCode >= 500 || statusCode == 429);

      default:
        return false;
    }
  }
}
