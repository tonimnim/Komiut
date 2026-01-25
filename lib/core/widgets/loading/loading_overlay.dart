/// Loading Overlay - Full-screen loading overlay component.
///
/// Shows a semi-transparent overlay with a loading indicator
/// on top of the child content.
library;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// A loading overlay that shows a semi-transparent layer with a spinner.
///
/// Wrap this around content that may have a loading state to show
/// a loading indicator without replacing the content.
///
/// ```dart
/// LoadingOverlay(
///   isLoading: isSubmitting,
///   message: 'Processing payment...',
///   child: MyForm(),
/// )
/// ```
class LoadingOverlay extends StatelessWidget {
  /// Creates a LoadingOverlay.
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.overlayColor,
    this.indicatorColor,
    this.useGradient = false,
    this.dismissible = false,
    this.onDismiss,
  });

  /// Whether to show the loading overlay.
  final bool isLoading;

  /// The content to display beneath the overlay.
  final Widget child;

  /// Optional message to display below the loading indicator.
  final String? message;

  /// Color of the overlay background. Defaults to black with 50% opacity.
  final Color? overlayColor;

  /// Color of the loading indicator. Defaults to primary color.
  final Color? indicatorColor;

  /// Whether to use a gradient background for the overlay.
  final bool useGradient;

  /// Whether the overlay can be dismissed by tapping.
  final bool dismissible;

  /// Callback when the overlay is dismissed (only if dismissible is true).
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: _LoadingOverlayContent(
              message: message,
              overlayColor: overlayColor,
              indicatorColor: indicatorColor,
              useGradient: useGradient,
              dismissible: dismissible,
              onDismiss: onDismiss,
            ),
          ),
      ],
    );
  }
}

class _LoadingOverlayContent extends StatelessWidget {
  const _LoadingOverlayContent({
    this.message,
    this.overlayColor,
    this.indicatorColor,
    this.useGradient = false,
    this.dismissible = false,
    this.onDismiss,
  });

  final String? message;
  final Color? overlayColor;
  final Color? indicatorColor;
  final bool useGradient;
  final bool dismissible;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: dismissible ? onDismiss : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: useGradient
              ? null
              : (overlayColor ?? Colors.black.withValues(alpha: 0.5)),
          gradient: useGradient
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryBlue.withValues(alpha: 0.8),
                    AppColors.primaryGreen.withValues(alpha: 0.8),
                  ],
                )
              : null,
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      indicatorColor ?? theme.colorScheme.primary,
                    ),
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A full-screen loading overlay that covers the entire screen.
///
/// Use this for blocking operations like form submissions or
/// navigation transitions.
class FullScreenLoadingOverlay extends StatelessWidget {
  /// Creates a FullScreenLoadingOverlay.
  const FullScreenLoadingOverlay({
    super.key,
    this.message,
    this.useGradient = true,
  });

  /// Optional message to display.
  final String? message;

  /// Whether to use a gradient background.
  final bool useGradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: useGradient
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryBlue, AppColors.primaryGreen],
                )
              : null,
          color: useGradient ? null : theme.colorScheme.surface,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    useGradient ? Colors.white : theme.colorScheme.primary,
                  ),
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 24),
                Text(
                  message!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: useGradient
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A modal barrier that prevents interaction with content behind it.
///
/// Use this for temporary loading states that should block user input.
class LoadingBarrier extends StatelessWidget {
  /// Creates a LoadingBarrier.
  const LoadingBarrier({
    super.key,
    this.isLoading = true,
  });

  /// Whether the barrier is active.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();

    return const ModalBarrier(
      dismissible: false,
      color: Colors.transparent,
    );
  }
}
