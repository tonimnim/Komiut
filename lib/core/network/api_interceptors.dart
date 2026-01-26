/// API interceptors for Dio client.
///
/// Provides interceptors for authentication, logging, and error handling.
/// Includes token refresh with request queuing for concurrent requests.
library;

import 'dart:async';
import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';
import '../config/env_config.dart';
import 'api_endpoints.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Auth Session Callback Type
// ─────────────────────────────────────────────────────────────────────────────

/// Callback type for auth session events.
///
/// Used to notify the auth layer about session expiry without importing UI code.
typedef AuthSessionExpiredCallback = void Function();

/// Controller for auth session events.
///
/// Allows the auth layer to subscribe to session expiry events.
class AuthSessionController {
  AuthSessionController._();

  static final AuthSessionController instance = AuthSessionController._();

  final _expiredController = StreamController<void>.broadcast();

  /// Stream that emits when the auth session expires.
  Stream<void> get onSessionExpired => _expiredController.stream;

  /// Notify listeners that the session has expired.
  void notifySessionExpired() {
    dev.log('AuthSessionController: Session expired, notifying listeners');
    _expiredController.add(null);
  }

  /// Dispose the controller.
  void dispose() {
    _expiredController.close();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth Interceptor with Token Refresh
// ─────────────────────────────────────────────────────────────────────────────

/// Interceptor for adding authentication headers and handling token refresh.
///
/// Uses [QueuedInterceptor] to automatically queue concurrent requests
/// during token refresh, preventing race conditions.
class AuthInterceptor extends QueuedInterceptor {
  /// Creates an auth interceptor with the given secure storage.
  ///
  /// [storage] - Secure storage instance for reading/writing tokens.
  /// [dio] - Optional Dio instance for making refresh requests. If not provided,
  ///         a new instance will be created.
  AuthInterceptor(
    this._storage, {
    Dio? dio,
  }) : _refreshDio = dio ?? _createRefreshDio();

  final FlutterSecureStorage _storage;
  final Dio _refreshDio;

  /// Whether a token refresh is currently in progress.
  bool _isRefreshing = false;

  /// Creates a Dio instance specifically for token refresh.
  ///
  /// This instance doesn't have auth interceptors to avoid infinite loops.
  static Dio _createRefreshDio() {
    return Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout:
            const Duration(milliseconds: AppConfig.apiConnectTimeoutMs),
        receiveTimeout:
            const Duration(milliseconds: AppConfig.apiReceiveTimeoutMs),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get access token from secure storage
    final token = await _storage.read(key: AppConfig.accessTokenKey);

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 Unauthorized errors
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Check if this is already a refresh token request to avoid infinite loop
    if (err.requestOptions.path.contains('refresh-token')) {
      dev.log('AuthInterceptor: Refresh token request failed with 401');
      await _handleRefreshFailure();
      handler.next(err);
      return;
    }

    dev.log('AuthInterceptor: 401 detected, attempting token refresh');

    // If already refreshing, wait and retry (QueuedInterceptor handles queuing)
    if (_isRefreshing) {
      dev.log('AuthInterceptor: Token refresh already in progress, waiting');
      // The QueuedInterceptor will automatically queue this request
      handler.next(err);
      return;
    }

    // Attempt to refresh the token
    final refreshSuccess = await _attemptTokenRefresh();

    if (refreshSuccess) {
      dev.log('AuthInterceptor: Token refresh successful, retrying request');
      try {
        // Get the new token and retry the original request
        final newToken = await _storage.read(key: AppConfig.accessTokenKey);
        if (newToken != null) {
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';

          // Retry the original request with the new token
          final response = await _refreshDio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        }
      } catch (e) {
        dev.log('AuthInterceptor: Retry failed: $e');
        // Fall through to error handling
      }
    }

    // Refresh failed, clear tokens and notify auth layer
    dev.log('AuthInterceptor: Token refresh failed, session expired');
    await _handleRefreshFailure();
    handler.next(err);
  }

  /// Attempts to refresh the access token.
  ///
  /// Returns `true` if refresh was successful, `false` otherwise.
  Future<bool> _attemptTokenRefresh() async {
    _isRefreshing = true;

    try {
      final refreshToken = await _storage.read(key: AppConfig.refreshTokenKey);

      if (refreshToken == null || refreshToken.isEmpty) {
        dev.log('AuthInterceptor: No refresh token available');
        return false;
      }

      dev.log('AuthInterceptor: Refreshing token...');

      final response = await _refreshDio.post<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          // Store new tokens
          await _storage.write(
            key: AppConfig.accessTokenKey,
            value: newAccessToken,
          );

          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await _storage.write(
              key: AppConfig.refreshTokenKey,
              value: newRefreshToken,
            );
          }

          dev.log('AuthInterceptor: Tokens updated successfully');
          return true;
        }
      }

      dev.log('AuthInterceptor: Token refresh response invalid');
      return false;
    } on DioException catch (e) {
      dev.log('AuthInterceptor: Token refresh failed: ${e.message}');
      return false;
    } catch (e) {
      dev.log('AuthInterceptor: Token refresh error: $e');
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Handles token refresh failure by clearing stored tokens and notifying listeners.
  Future<void> _handleRefreshFailure() async {
    // Clear stored tokens
    await _storage.delete(key: AppConfig.accessTokenKey);
    await _storage.delete(key: AppConfig.refreshTokenKey);
    await _storage.delete(key: AppConfig.userIdKey);
    await _storage.delete(key: AppConfig.userRoleKey);

    // Notify auth layer about session expiry
    AuthSessionController.instance.notifySessionExpired();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logging Interceptor
// ─────────────────────────────────────────────────────────────────────────────

/// Interceptor for logging requests and responses.
class LoggingInterceptor extends Interceptor {
  void _log(String message) {
    // Use print for terminal output (dev.log only shows in DevTools)
    // ignore: avoid_print
    print(message);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (EnvConfig.enableApiLogging) {
      _log('══════════════════════════════════════════════════════════════');
      _log('🚀 REQUEST: ${options.method} ${options.uri}');
      _log('   Headers: ${options.headers}');
      if (options.data != null) {
        _log('   Body: ${options.data}');
      }
      if (options.queryParameters.isNotEmpty) {
        _log('   Query: ${options.queryParameters}');
      }
      _log('══════════════════════════════════════════════════════════════');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (EnvConfig.enableApiLogging) {
      _log('══════════════════════════════════════════════════════════════');
      _log('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
      _log('   Data: ${response.data}');
      _log('══════════════════════════════════════════════════════════════');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (EnvConfig.enableLogging) {
      _log('══════════════════════════════════════════════════════════════');
      _log('❌ ERROR: ${err.type}');
      _log('   Message: ${err.message}');
      _log('   URL: ${err.requestOptions.uri}');
      if (err.response != null) {
        _log('   Status: ${err.response?.statusCode}');
        _log('   Data: ${err.response?.data}');
      }
      _log('══════════════════════════════════════════════════════════════');
    }
    handler.next(err);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error Interceptor
// ─────────────────────────────────────────────────────────────────────────────

/// Interceptor for handling errors and converting them to app exceptions.
///
/// This interceptor runs after [AuthInterceptor], so 401 errors here mean
/// token refresh has already failed.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Transform DioException to more specific types if needed
    final response = err.response;

    if (response != null) {
      // Server responded with an error status code
      final statusCode = response.statusCode;
      String message = _extractErrorMessage(response.data);

      switch (statusCode) {
        case 400:
          message = message.isNotEmpty ? message : 'Bad request';
        case 401:
          // At this point, token refresh has already been attempted and failed
          message = message.isNotEmpty ? message : 'Session expired';
          dev.log(
              'ErrorInterceptor: 401 after token refresh - session expired');
        case 403:
          message = message.isNotEmpty ? message : 'Access denied';
        case 404:
          message = message.isNotEmpty ? message : 'Resource not found';
        case 422:
          message = message.isNotEmpty ? message : 'Validation error';
        case 429:
          message = message.isNotEmpty ? message : 'Too many requests';
        case 500:
          message = message.isNotEmpty ? message : 'Server error';
        case 503:
          message = message.isNotEmpty ? message : 'Service unavailable';
        default:
          message = message.isNotEmpty ? message : 'Request failed';
      }

      handler.next(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: err.type,
          error: message,
          message: message,
        ),
      );
      return;
    }

    // Handle connection errors
    String message;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet.';
      case DioExceptionType.sendTimeout:
        message = 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        message = 'Server is taking too long to respond.';
      case DioExceptionType.connectionError:
        message = 'No internet connection.';
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
      default:
        message = err.message ?? 'An unexpected error occurred.';
    }

    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: message,
        message: message,
      ),
    );
  }

  /// Extracts error message from response data.
  String _extractErrorMessage(dynamic data) {
    if (data == null) return '';

    if (data is String) return data;

    if (data is Map<String, dynamic>) {
      // Common API error response formats
      return data['message'] as String? ??
          data['error'] as String? ??
          data['errorMessage'] as String? ??
          data['detail'] as String? ??
          '';
    }

    return '';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Retry Interceptor
// ─────────────────────────────────────────────────────────────────────────────

/// Interceptor for automatic request retry with exponential backoff.
///
/// Retries on:
/// - Connection timeout
/// - Receive timeout
/// - Send timeout
/// - Server errors (500, 502, 503)
///
/// Does NOT retry on:
/// - Client errors (400, 401, 403, 404)
/// - Cancelled requests
class RetryInterceptor extends Interceptor {
  /// Creates a retry interceptor.
  ///
  /// [dio] - Dio instance for retrying requests.
  /// [maxRetries] - Maximum number of retry attempts (default: 3).
  /// [baseDelayMs] - Base delay in milliseconds for exponential backoff (default: 1000).
  RetryInterceptor({
    required Dio dio,
    this.maxRetries = AppConfig.maxRetryAttempts,
    this.baseDelayMs = AppConfig.retryDelayMs,
  }) : _dio = dio;

  final Dio _dio;

  /// Maximum number of retry attempts.
  final int maxRetries;

  /// Base delay in milliseconds for exponential backoff.
  final int baseDelayMs;

  /// Custom header to track retry attempts.
  static const String _retryCountHeader = 'x-retry-count';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Check if the error is retryable
    if (!_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    // Get current retry count
    final retryCount =
        (err.requestOptions.headers[_retryCountHeader] as int?) ?? 0;

    if (retryCount >= maxRetries) {
      dev.log(
          'RetryInterceptor: Max retries ($maxRetries) reached for ${err.requestOptions.uri}');
      handler.next(err);
      return;
    }

    // Calculate delay with exponential backoff: 1s, 2s, 4s, ...
    final delayMs = baseDelayMs * (1 << retryCount);
    dev.log(
        'RetryInterceptor: Retry ${retryCount + 1}/$maxRetries for ${err.requestOptions.uri} after ${delayMs}ms');

    // Wait before retrying
    await Future<void>.delayed(Duration(milliseconds: delayMs));

    // Update retry count in headers
    err.requestOptions.headers[_retryCountHeader] = retryCount + 1;

    try {
      // Retry the request
      final response = await _dio.fetch(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      // Recursively handle the error (may retry again)
      onError(e, handler);
    }
  }

  /// Determines if a request should be retried based on the error type.
  bool _shouldRetry(DioException err) {
    // Retry on timeout errors
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return true;
    }

    // Retry on server errors (5xx)
    final statusCode = err.response?.statusCode;
    if (statusCode != null) {
      // Retry on 500, 502, 503
      if (statusCode >= 500 && statusCode <= 503) {
        return true;
      }

      // Don't retry on client errors (4xx)
      if (statusCode >= 400 && statusCode < 500) {
        return false;
      }
    }

    // Retry on connection errors (network issues)
    if (err.type == DioExceptionType.connectionError) {
      return true;
    }

    // Don't retry on cancelled requests
    if (err.type == DioExceptionType.cancel) {
      return false;
    }

    return false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for secure storage.
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
});

/// Provider for auth session expired stream.
///
/// Use this in your auth controller to listen for session expiry events:
/// ```dart
/// ref.listen(authSessionExpiredProvider, (_, __) {
///   // Handle session expiry (e.g., navigate to login)
/// });
/// ```
final authSessionExpiredProvider = StreamProvider<void>((ref) {
  return AuthSessionController.instance.onSessionExpired;
});
