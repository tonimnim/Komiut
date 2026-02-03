/// Error Handler - Utility for handling and displaying errors.
///
/// Provides methods for converting errors to user-friendly messages
/// and displaying error feedback.
library;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../errors/failures.dart';
import '../theme/app_colors.dart';

/// Utility class for handling errors throughout the app.
///
/// ```dart
/// try {
///   await api.fetchData();
/// } on DioException catch (e) {
///   final failure = ErrorHandler.fromDioError(e);
///   ErrorHandler.showError(context, failure);
/// }
/// ```
class ErrorHandler {
  ErrorHandler._();

  /// Convert a [Failure] to a user-friendly message.
  ///
  /// Returns a localized, user-friendly error message based on the
  /// failure type.
  static String getMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (failure is ServerFailure) {
      final statusCode = failure.statusCode;
      if (statusCode != null) {
        return _getServerErrorMessage(statusCode, failure.message);
      }
      return failure.message.isNotEmpty
          ? failure.message
          : 'Server error. Please try again later.';
    }

    if (failure is AuthenticationFailure) {
      return failure.message.isNotEmpty
          ? failure.message
          : 'Authentication failed. Please sign in again.';
    }

    if (failure is ValidationFailure) {
      return failure.message.isNotEmpty
          ? failure.message
          : 'Invalid input. Please check your data and try again.';
    }

    if (failure is CacheFailure) {
      return 'Unable to load cached data. Please refresh.';
    }

    if (failure is DatabaseFailure) {
      return 'Database error. Please try again.';
    }

    if (failure is UnknownFailure) {
      return failure.message.isNotEmpty
          ? failure.message
          : 'An unexpected error occurred. Please try again.';
    }

    // Default fallback
    return failure.message.isNotEmpty
        ? failure.message
        : 'Something went wrong. Please try again.';
  }

  /// Get a user-friendly message for HTTP status codes.
  static String _getServerErrorMessage(int statusCode, String fallback) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Session expired. Please sign in again.';
      case 403:
        return 'You don\'t have permission to access this resource.';
      case 404:
        return 'The requested resource was not found.';
      case 408:
        return 'Request timed out. Please try again.';
      case 409:
        return 'Conflict with current state. Please refresh and try again.';
      case 422:
        return 'Invalid data provided. Please check your input.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Service temporarily unavailable. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      case 504:
        return 'Server timed out. Please try again later.';
      default:
        if (statusCode >= 500) {
          return 'Server error. Please try again later.';
        }
        return fallback.isNotEmpty ? fallback : 'An error occurred.';
    }
  }

  /// Convert a [DioException] to a [Failure].
  ///
  /// Handles various Dio error types and converts them to appropriate
  /// failure types for the app.
  static Failure fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          'Connection timed out. Please check your internet connection.',
        );

      case DioExceptionType.connectionError:
        return const NetworkFailure(
          'Unable to connect. Please check your internet connection.',
        );

      case DioExceptionType.badCertificate:
        return const ServerFailure(
          'Security certificate error. Please contact support.',
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);

      case DioExceptionType.cancel:
        return const UnknownFailure('Request was cancelled.');

      case DioExceptionType.unknown:
        if (error.error.toString().contains('SocketException') ||
            error.error.toString().contains('HandshakeException')) {
          return const NetworkFailure(
            'No internet connection. Please check your network.',
          );
        }
        return UnknownFailure(
          error.message ?? 'An unexpected error occurred.',
        );
    }
  }

  /// Handle bad response from server.
  static Failure _handleBadResponse(Response? response) {
    if (response == null) {
      return const ServerFailure('No response from server.');
    }

    final statusCode = response.statusCode ?? 500;
    final data = response.data;

    // Try to extract error message from response
    String? message;
    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ??
          data['error'] as String? ??
          data['detail'] as String?;
    }

    // Handle specific status codes
    switch (statusCode) {
      case 401:
        return AuthenticationFailure(message ?? 'Authentication required.');
      case 403:
        return AuthenticationFailure(message ?? 'Access denied.');
      case 422:
        return ValidationFailure(message ?? 'Validation error.');
      default:
        return ServerFailure(
          message ?? 'Server error.',
          statusCode: statusCode,
        );
    }
  }

  /// Check if an error is retryable.
  ///
  /// Returns true if the error is likely to succeed on retry
  /// (e.g., network errors, timeouts, temporary server errors).
  static bool isRetryable(Failure failure) {
    if (failure is NetworkFailure) {
      return true;
    }

    if (failure is ServerFailure) {
      final statusCode = failure.statusCode;
      if (statusCode == null) return true;

      // Retry on server errors and rate limiting
      return statusCode >= 500 || statusCode == 408 || statusCode == 429;
    }

    if (failure is CacheFailure) {
      return true;
    }

    // Don't retry auth, validation, or unknown errors
    return false;
  }

  /// Get the appropriate error type for a failure.
  ///
  /// Used for determining which error widget variant to show.
  static ErrorCategory getErrorCategory(Failure failure) {
    if (failure is NetworkFailure) {
      return ErrorCategory.network;
    }

    if (failure is AuthenticationFailure) {
      return ErrorCategory.auth;
    }

    if (failure is ServerFailure) {
      final statusCode = failure.statusCode;
      if (statusCode == 404) {
        return ErrorCategory.notFound;
      }
      return ErrorCategory.server;
    }

    if (failure is ValidationFailure) {
      return ErrorCategory.validation;
    }

    return ErrorCategory.unknown;
  }

  /// Show an error snackbar.
  ///
  /// Displays a snackbar with the error message and optional retry action.
  static void showError(
    BuildContext context,
    Failure failure, {
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    final message = getMessage(failure);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getIconForCategory(getErrorCategory(failure)),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: onRetry != null && isRetryable(failure)
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Show a success snackbar.
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show an info snackbar.
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: AppColors.info,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show a warning snackbar.
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.warning,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Get the appropriate icon for an error category.
  static IconData _getIconForCategory(ErrorCategory category) {
    switch (category) {
      case ErrorCategory.network:
        return Icons.wifi_off_rounded;
      case ErrorCategory.server:
        return Icons.cloud_off_rounded;
      case ErrorCategory.auth:
        return Icons.lock_outline_rounded;
      case ErrorCategory.notFound:
        return Icons.search_off_rounded;
      case ErrorCategory.validation:
        return Icons.error_outline_rounded;
      case ErrorCategory.unknown:
        return Icons.error_outline_rounded;
    }
  }
}

/// Categories of errors for UI display purposes.
enum ErrorCategory {
  /// Network connectivity issues.
  network,

  /// Server-side errors.
  server,

  /// Authentication/authorization errors.
  auth,

  /// Resource not found errors.
  notFound,

  /// Input validation errors.
  validation,

  /// Unknown/unexpected errors.
  unknown,
}

/// Extension on [Object] for convenient error handling.
extension ErrorHandlerX on Object {
  /// Convert any error to a Failure.
  Failure toFailure() {
    if (this is Failure) return this as Failure;
    if (this is DioException)
      return ErrorHandler.fromDioError(this as DioException);
    return UnknownFailure(toString());
  }
}
