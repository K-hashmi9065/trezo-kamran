/// Base exception for server-related errors
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ServerException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

/// Exception for local cache/storage errors
class CacheException implements Exception {
  final String message;
  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

/// Exception for network connectivity issues
class NetworkException implements Exception {
  final String message;
  final String? details;

  NetworkException(this.message, {this.details});

  @override
  String toString() => 'NetworkException: $message${details != null ? ' - $details' : ''}';
}

/// Exception for authentication failures (401)
class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException([this.message = 'Unauthorized access. Please login again.']);

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Exception for forbidden access (403)
class ForbiddenException implements Exception {
  final String message;

  ForbiddenException([this.message = 'Access forbidden. You don\'t have permission.']);

  @override
  String toString() => 'ForbiddenException: $message';
}

/// Exception for resource not found (404)
class NotFoundException implements Exception {
  final String message;
  final String? resource;

  NotFoundException(this.message, {this.resource});

  @override
  String toString() => 'NotFoundException: $message${resource != null ? ' ($resource)' : ''}';
}

/// Exception for request timeout
class TimeoutException implements Exception {
  final String message;
  final Duration? duration;

  TimeoutException([this.message = 'Request timeout', this.duration]);

  @override
  String toString() => 'TimeoutException: $message${duration != null ? ' (${duration!.inSeconds}s)' : ''}';
}

/// Exception for no internet connection
class NoInternetException implements Exception {
  final String message;

  NoInternetException([this.message = 'No internet connection. Please check your network.']);

  @override
  String toString() => 'NoInternetException: $message';
}

/// Exception for bad request (400)
class BadRequestException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;

  BadRequestException(this.message, {this.errors});

  @override
  String toString() => 'BadRequestException: $message${errors != null ? ' - Errors: $errors' : ''}';
}

/// Exception for validation errors
class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>>? fieldErrors;

  ValidationException(this.message, {this.fieldErrors});

  @override
  String toString() => 'ValidationException: $message';
}

/// Exception for conflict errors (409)
class ConflictException implements Exception {
  final String message;
  final dynamic conflictData;

  ConflictException(this.message, {this.conflictData});

  @override
  String toString() => 'ConflictException: $message';
}

/// Exception for too many requests (429)
class TooManyRequestsException implements Exception {
  final String message;
  final Duration? retryAfter;

  TooManyRequestsException([this.message = 'Too many requests. Please try again later.', this.retryAfter]);

  @override
  String toString() => 'TooManyRequestsException: $message';
}
