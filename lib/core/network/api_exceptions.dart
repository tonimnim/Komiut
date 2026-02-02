import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final dynamic details;

  ApiException({
    required this.message,
    this.code,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => 'ApiException: $message (code: $code)';

  factory ApiException.fromResponse(
      Map<String, dynamic> response, int? statusCode) {
    final error = response['error'] as Map<String, dynamic>?;
    return ApiException(
      message: error?['message'] ?? 'Unknown error',
      code: error?['code'],
      statusCode: statusCode,
      details: error?['details'],
    );
  }

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(message: 'Connection timed out');
      case DioExceptionType.badResponse:
        if (error.response?.data is Map<String, dynamic>) {
          return ApiException.fromResponse(
            error.response!.data as Map<String, dynamic>,
            error.response?.statusCode,
          );
        }
        return ApiException(
          message: 'Server error: ${error.response?.statusCode}',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return ApiException(message: 'Request cancelled');
      case DioExceptionType.connectionError:
        return ApiException(message: 'No internet connection');
      default:
        return ApiException(message: 'Something went wrong');
    }
  }
}

class NetworkException implements Exception {
  final String message;

  NetworkException([this.message = 'No internet connection']);

  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;

  AuthException([this.message = 'Authentication failed']);

  @override
  String toString() => 'AuthException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;

  ValidationException({
    required this.message,
    this.errors,
  });

  @override
  String toString() => 'ValidationException: $message';
}

class ServerException implements Exception {
  final String message;

  ServerException([this.message = 'Server error occurred']);

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;

  CacheException([this.message = 'Cache error occurred']);

  @override
  String toString() => 'CacheException: $message';
}
