/// Base class for all failures
abstract class Failure {
  final String message;
  Failure(this.message);

  @override
  String toString() => message;
}

/// Failure for server-related errors
class ServerFailure extends Failure {
  final int? statusCode;
  ServerFailure(super.message, {this.statusCode});
}

/// Failure for local cache/storage errors
class CacheFailure extends Failure {
  CacheFailure(super.message);
}

/// Failure for network connectivity issues
class NetworkFailure extends Failure {
  NetworkFailure(super.message);
}

/// Failure for authentication errors (401)
class UnauthorizedFailure extends Failure {
  UnauthorizedFailure([super.message = 'Session expired. Please login again.']);
}

/// Failure for forbidden access (403)
class ForbiddenFailure extends Failure {
  ForbiddenFailure([
    super.message = 'You don\'t have permission to access this resource.',
  ]);
}

/// Failure for resource not found (404)
class NotFoundFailure extends Failure {
  NotFoundFailure(super.message);
}

/// Failure for request timeout
class TimeoutFailure extends Failure {
  TimeoutFailure([super.message = 'Request took too long. Please try again.']);
}

/// Failure for no internet connection
class NoInternetFailure extends Failure {
  NoInternetFailure([
    super.message = 'No internet connection. Check your network and try again.',
  ]);
}

/// Failure for bad request (400)
class BadRequestFailure extends Failure {
  final Map<String, dynamic>? errors;
  BadRequestFailure(super.message, {this.errors});
}

/// Failure for validation errors
class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;
  ValidationFailure(super.message, {this.fieldErrors});
}

/// Failure for conflict errors (409)
class ConflictFailure extends Failure {
  ConflictFailure(super.message);
}

/// Failure for too many requests (429)
class TooManyRequestsFailure extends Failure {
  TooManyRequestsFailure([
    super.message = 'Too many requests. Please wait and try again.',
  ]);
}
