/// API client implementation using Dio.
///
/// Provides a configured Dio instance with interceptors for
/// authentication, logging, error handling, and automatic retry.
library;

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../errors/failures.dart';
import 'api_interceptors.dart';
import 'api_response.dart';
import 'network_info.dart';

/// Provider for the API client.
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return ApiClient(storage: storage, networkInfo: networkInfo);
});

/// HTTP client for API requests.
///
/// Wraps Dio with proper configuration, interceptors, and error handling.
/// Includes automatic retry with exponential backoff for transient failures.
class ApiClient {
  /// Creates an API client with the given dependencies.
  ApiClient({
    required dynamic storage,
    required NetworkInfo networkInfo,
  }) : _networkInfo = networkInfo {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(milliseconds: AppConfig.apiConnectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: AppConfig.apiReceiveTimeoutMs),
        sendTimeout: const Duration(milliseconds: AppConfig.apiTimeoutMs),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors in order:
    // 1. AuthInterceptor - Adds auth headers and handles token refresh
    // 2. RetryInterceptor - Retries on transient failures (must be before logging)
    // 3. LoggingInterceptor - Logs requests/responses
    // 4. ErrorInterceptor - Transforms errors to user-friendly messages
    _dio.interceptors.addAll([
      AuthInterceptor(storage),
      RetryInterceptor(dio: _dio),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Driver Compatibility Methods (Internal)
  // ─────────────────────────────────────────────────────────────────────────

  Future<DriverResponse> getDriver(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    final result = await get<dynamic>(path, queryParameters: queryParameters, options: options);
    return result.fold(
      (failure) => throw ServerFailure(failure.message),
      (data) => DriverResponse(data),
    );
  }

  Future<DriverResponse> postDriver(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    final result = await post<dynamic>(path, data: data, queryParameters: queryParameters, options: options);
    return result.fold(
      (failure) => throw ServerFailure(failure.message),
      (data) => DriverResponse(data),
    );
  }

  Future<DriverResponse> putDriver(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    final result = await put<dynamic>(path, data: data, queryParameters: queryParameters, options: options);
    return result.fold(
      (failure) => throw ServerFailure(failure.message),
      (data) => DriverResponse(data),
    );
  }

  Future<DriverResponse> deleteDriver(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    final result = await delete<dynamic>(path, data: data, queryParameters: queryParameters, options: options);
    return result.fold(
      (failure) => throw ServerFailure(failure.message),
      (data) => DriverResponse(data),
    );
  }

  late final Dio _dio;
  final NetworkInfo _networkInfo;

  Dio get dio => _dio;

  // ─────────────────────────────────────────────────────────────────────────
  // HTTP Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Performs a GET request.
  Future<Either<Failure, T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
  }) async {
    return _executeRequest(
      () => _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
      ),
      fromJson: fromJson,
    );
  }

  /// Performs a POST request.
  Future<Either<Failure, T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
  }) async {
    return _executeRequest(
      () => _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      fromJson: fromJson,
    );
  }

  /// Performs a PUT request.
  Future<Either<Failure, T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
  }) async {
    return _executeRequest(
      () => _dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      fromJson: fromJson,
    );
  }

  /// Performs a PATCH request.
  Future<Either<Failure, T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
  }) async {
    return _executeRequest(
      () => _dio.patch<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      fromJson: fromJson,
    );
  }

  /// Performs a DELETE request.
  Future<Either<Failure, T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
  }) async {
    return _executeRequest(
      () => _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      fromJson: fromJson,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Specialized Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Fetches a paginated list of items.
  Future<Either<Failure, PaginatedResponse<T>>> getPaginated<T>(
    String path, {
    int page = 1,
    int pageSize = AppConfig.defaultPageSize,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
    Options? options,
  }) async {
    final params = {
      'page': page,
      'pageSize': pageSize,
      ...?queryParameters,
    };

    return _executeRequest(
      () => _dio.get<dynamic>(
        path,
        queryParameters: params,
        options: options,
      ),
      fromJson: (data) => PaginatedResponse.fromJson(
        data as Map<String, dynamic>,
        fromJson,
      ),
    );
  }

  /// Uploads a file with multipart form data.
  Future<Either<Failure, T>> uploadFile<T>(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? additionalFields,
    T Function(dynamic)? fromJson,
    void Function(int, int)? onProgress,
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
      ...?additionalFields,
    });

    return _executeRequest(
      () => _dio.post<dynamic>(
        path,
        data: formData,
        onSendProgress: onProgress,
      ),
      fromJson: fromJson,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Executes a request with error handling.
  Future<Either<Failure, T>> _executeRequest<T>(
    Future<Response<dynamic>> Function() request, {
    T Function(dynamic)? fromJson,
  }) async {
    // Check connectivity first
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final response = await request();

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        if (fromJson != null && response.data != null) {
          return Right(fromJson(response.data));
        }
        // For void or untyped responses
        return Right(response.data as T);
      }

      return Left(
        ServerFailure(
          'Request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
        ),
      );
    } on DioException catch (e) {
      return Left(_mapDioException(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Maps DioException to Failure.
  Failure _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timeout');

      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.message ?? 'Server error';

        if (statusCode == 401) {
          return AuthenticationFailure(message);
        }
        if (statusCode == 422) {
          return ValidationFailure(message);
        }
        return ServerFailure(message, statusCode: statusCode);

      case DioExceptionType.cancel:
        return const ServerFailure('Request cancelled');

      default:
        return ServerFailure(e.message ?? 'Unknown error');
    }
  }
}

class DriverResponse {
  final dynamic data;
  DriverResponse(this.data);
}
