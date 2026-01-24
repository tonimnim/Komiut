/// AppError - Error display components.
///
/// Widgets for displaying error states and messages.
library;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../buttons/app_button.dart';

/// Types of errors that can be displayed.
enum ErrorType {
  /// Network connectivity error.
  network,

  /// Server/API error.
  server,

  /// Resource not found error.
  notFound,

  /// Authentication/authorization error.
  unauthorized,

  /// Generic/unknown error.
  generic,
}

/// An error message display widget with support for different error types.
///
/// ```dart
/// AppErrorWidget(
///   title: 'Error',
///   message: 'Something went wrong',
///   type: ErrorType.server,
///   onRetry: () => _fetchData(),
/// )
/// ```
class AppErrorWidget extends StatelessWidget {
  /// Creates an AppErrorWidget.
  const AppErrorWidget({
    super.key,
    required this.title,
    this.message,
    this.onRetry,
    this.type = ErrorType.generic,
    this.showIcon = true,
    this.retryLabel = 'Retry',
    this.customIcon,
    this.iconColor,
    this.compact = false,
  });

  /// Creates a network error widget.
  factory AppErrorWidget.network({
    Key? key,
    VoidCallback? onRetry,
    String? message,
  }) {
    return AppErrorWidget(
      key: key,
      title: 'Connection Error',
      message: message ?? 'No internet connection. Please check your network.',
      type: ErrorType.network,
      onRetry: onRetry,
    );
  }

  /// Creates a server error widget.
  factory AppErrorWidget.server({
    Key? key,
    VoidCallback? onRetry,
    String? message,
  }) {
    return AppErrorWidget(
      key: key,
      title: 'Server Error',
      message: message ?? 'Something went wrong. Please try again later.',
      type: ErrorType.server,
      onRetry: onRetry,
    );
  }

  /// Creates a not found error widget.
  factory AppErrorWidget.notFound({
    Key? key,
    VoidCallback? onRetry,
    String? message,
  }) {
    return AppErrorWidget(
      key: key,
      title: 'Not Found',
      message: message ?? 'The requested item could not be found.',
      type: ErrorType.notFound,
      onRetry: onRetry,
      retryLabel: 'Go Back',
    );
  }

  /// Creates an unauthorized error widget.
  factory AppErrorWidget.unauthorized({
    Key? key,
    VoidCallback? onRetry,
    String? message,
  }) {
    return AppErrorWidget(
      key: key,
      title: 'Access Denied',
      message: message ?? 'You are not authorized to view this content.',
      type: ErrorType.unauthorized,
      onRetry: onRetry,
      retryLabel: 'Sign In',
    );
  }

  /// Title of the error.
  final String title;

  /// Optional detailed error message.
  final String? message;

  /// Callback when retry is pressed.
  final VoidCallback? onRetry;

  /// Type of error for icon selection.
  final ErrorType type;

  /// Whether to show the error icon.
  final bool showIcon;

  /// Label for the retry button.
  final String retryLabel;

  /// Custom icon to override the type-based icon.
  final IconData? customIcon;

  /// Custom icon color.
  final Color? iconColor;

  /// Whether to use compact layout.
  final bool compact;

  /// Get the appropriate icon for the error type.
  IconData get _icon {
    if (customIcon != null) return customIcon!;
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off_rounded;
      case ErrorType.server:
        return Icons.cloud_off_rounded;
      case ErrorType.notFound:
        return Icons.search_off_rounded;
      case ErrorType.unauthorized:
        return Icons.lock_outline_rounded;
      case ErrorType.generic:
        return Icons.error_outline_rounded;
    }
  }

  /// Get the appropriate icon color for the error type.
  Color _getIconColor(ThemeData theme) {
    if (iconColor != null) return iconColor!;
    switch (type) {
      case ErrorType.network:
        return AppColors.warning;
      case ErrorType.server:
        return theme.colorScheme.error;
      case ErrorType.notFound:
        return AppColors.textSecondary;
      case ErrorType.unauthorized:
        return AppColors.secondaryOrange;
      case ErrorType.generic:
        return theme.colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconSize = compact ? 48.0 : 72.0;
    final spacing = compact ? 12.0 : 16.0;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 16 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Container(
                padding: EdgeInsets.all(compact ? 12 : 16),
                decoration: BoxDecoration(
                  color: _getIconColor(theme).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _icon,
                  size: iconSize,
                  color: _getIconColor(theme).withValues(alpha: 0.8),
                ),
              ),
              SizedBox(height: spacing),
            ],
            Text(
              title,
              style: (compact
                      ? theme.textTheme.titleMedium
                      : theme.textTheme.titleLarge)
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              SizedBox(height: spacing / 2),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              SizedBox(height: spacing * 1.5),
              AppButton.outlined(
                label: retryLabel,
                onPressed: onRetry,
                icon: Icons.refresh_rounded,
                size: compact ? ButtonSize.small : ButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Legacy error widget - maintained for backwards compatibility.
///
/// Use [AppErrorWidget] for new implementations.
class AppError extends StatelessWidget {
  /// Creates an AppError widget.
  const AppError({
    super.key,
    required this.message,
    this.icon,
    this.onRetry,
    this.retryLabel = 'Retry',
    this.title,
  });

  /// Creates a network error display.
  const AppError.network({
    super.key,
    this.message = 'No internet connection. Please check your network.',
    this.onRetry,
    this.retryLabel = 'Retry',
  })  : icon = Icons.wifi_off,
        title = 'Connection Error';

  /// Creates a server error display.
  const AppError.server({
    super.key,
    this.message = 'Something went wrong. Please try again later.',
    this.onRetry,
    this.retryLabel = 'Retry',
  })  : icon = Icons.cloud_off,
        title = 'Server Error';

  /// Creates a not found error display.
  const AppError.notFound({
    super.key,
    this.message = 'The requested item could not be found.',
    this.onRetry,
    this.retryLabel = 'Go Back',
  })  : icon = Icons.search_off,
        title = 'Not Found';

  /// Error message text.
  final String message;

  /// Optional icon.
  final IconData? icon;

  /// Callback when retry is pressed.
  final VoidCallback? onRetry;

  /// Label for retry button.
  final String retryLabel;

  /// Optional title.
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 64,
                color: theme.colorScheme.error.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
            ],
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              AppButton.outlined(
                label: retryLabel,
                onPressed: onRetry,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// An inline error message.
class AppErrorInline extends StatelessWidget {
  /// Creates an inline error message.
  const AppErrorInline({
    super.key,
    required this.message,
    this.onDismiss,
  });

  /// Error message.
  final String message;

  /// Callback when dismissed.
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.onErrorContainer,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: Icon(
                Icons.close,
                color: theme.colorScheme.onErrorContainer,
                size: 18,
              ),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
