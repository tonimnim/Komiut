/// AppSnackbar - Snackbar helper utilities.
///
/// Helper functions for showing consistent snackbars.
library;

import 'package:flutter/material.dart';

/// Snackbar type for different contexts.
enum SnackbarType {
  /// Informational message.
  info,

  /// Success message.
  success,

  /// Warning message.
  warning,

  /// Error message.
  error,
}

/// Helper class for showing snackbars.
class AppSnackbar {
  const AppSnackbar._();

  /// Shows an info snackbar.
  static void info(BuildContext context, String message) {
    _show(context, message, SnackbarType.info);
  }

  /// Shows a success snackbar.
  static void success(BuildContext context, String message) {
    _show(context, message, SnackbarType.success);
  }

  /// Shows a warning snackbar.
  static void warning(BuildContext context, String message) {
    _show(context, message, SnackbarType.warning);
  }

  /// Shows an error snackbar.
  static void error(BuildContext context, String message) {
    _show(context, message, SnackbarType.error);
  }

  /// Shows a snackbar with action.
  static void withAction(
    BuildContext context,
    String message, {
    required String actionLabel,
    required VoidCallback onAction,
    SnackbarType type = SnackbarType.info,
  }) {
    _show(
      context,
      message,
      type,
      action: SnackBarAction(
        label: actionLabel,
        onPressed: onAction,
      ),
    );
  }

  static void _show(
    BuildContext context,
    String message,
    SnackbarType type, {
    SnackBarAction? action,
  }) {
    final theme = Theme.of(context);

    final (backgroundColor, textColor, icon) = switch (type) {
      SnackbarType.info => (
          theme.colorScheme.inverseSurface,
          theme.colorScheme.onInverseSurface,
          Icons.info_outline,
        ),
      SnackbarType.success => (
          Colors.green.shade700,
          Colors.white,
          Icons.check_circle_outline,
        ),
      SnackbarType.warning => (
          Colors.orange.shade700,
          Colors.white,
          Icons.warning_amber_outlined,
        ),
      SnackbarType.error => (
          theme.colorScheme.error,
          theme.colorScheme.onError,
          Icons.error_outline,
        ),
    };

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: action,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
