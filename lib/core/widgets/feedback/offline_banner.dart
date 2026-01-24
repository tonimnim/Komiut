/// Offline Banner - Animated banner for offline state indication.
///
/// Provides multiple display styles:
/// - Banner (persistent top bar)
/// - Snackbar (temporary notification)
/// - Overlay (modal-like coverage)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/connectivity_providers.dart';
import '../../theme/app_colors.dart';

/// Style options for offline banner.
enum OfflineBannerStyle {
  /// Persistent banner at top/bottom of screen.
  banner,

  /// Temporary snackbar-style notification.
  snackbar,

  /// Overlay covering content.
  overlay,
}

/// An animated banner that shows when the device is offline.
///
/// Slides in/out smoothly based on connectivity state.
///
/// ```dart
/// OfflineBanner(
///   onRetry: () => checkConnection(),
///   style: OfflineBannerStyle.banner,
/// )
/// ```
class OfflineBanner extends ConsumerStatefulWidget {
  /// Creates an offline banner.
  const OfflineBanner({
    super.key,
    this.onRetry,
    this.style = OfflineBannerStyle.banner,
    this.message = "You're offline",
    this.retryLabel = 'Retry',
    this.showRetry = true,
    this.showPendingCount = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.position = OfflineBannerPosition.top,
    this.child,
  });

  /// Callback when retry is pressed.
  final VoidCallback? onRetry;

  /// Display style.
  final OfflineBannerStyle style;

  /// Message to display.
  final String message;

  /// Label for retry button.
  final String retryLabel;

  /// Whether to show retry button.
  final bool showRetry;

  /// Whether to show pending sync count.
  final bool showPendingCount;

  /// Animation duration.
  final Duration animationDuration;

  /// Position of the banner.
  final OfflineBannerPosition position;

  /// Child widget (for overlay style).
  final Widget? child;

  @override
  ConsumerState<OfflineBanner> createState() => _OfflineBannerState();
}

/// Position options for the banner.
enum OfflineBannerPosition {
  /// Show at top of screen.
  top,

  /// Show at bottom of screen.
  bottom,
}

class _OfflineBannerState extends ConsumerState<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    final slideBegin = widget.position == OfflineBannerPosition.top
        ? const Offset(0, -1)
        : const Offset(0, 1);

    _slideAnimation = Tween<Offset>(
      begin: slideBegin,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineStateProvider);
    final pendingCount = ref.watch(pendingSyncCountProvider);

    // Animate based on online status
    if (!isOnline) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    switch (widget.style) {
      case OfflineBannerStyle.banner:
        return _buildBanner(context, isOnline, pendingCount);
      case OfflineBannerStyle.snackbar:
        return _buildSnackbarStyle(context, isOnline, pendingCount);
      case OfflineBannerStyle.overlay:
        return _buildOverlay(context, isOnline, pendingCount);
    }
  }

  Widget _buildBanner(BuildContext context, bool isOnline, int pendingCount) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.isDismissed) {
          return const SizedBox.shrink();
        }

        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: child,
          ),
        );
      },
      child: _BannerContent(
        message: widget.message,
        retryLabel: widget.retryLabel,
        showRetry: widget.showRetry,
        showPendingCount: widget.showPendingCount,
        pendingCount: pendingCount,
        onRetry: widget.onRetry,
        position: widget.position,
      ),
    );
  }

  Widget _buildSnackbarStyle(
    BuildContext context,
    bool isOnline,
    int pendingCount,
  ) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.isDismissed) {
          return const SizedBox.shrink();
        }

        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        );
      },
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(8),
        child: _SnackbarContent(
          message: widget.message,
          retryLabel: widget.retryLabel,
          showRetry: widget.showRetry,
          showPendingCount: widget.showPendingCount,
          pendingCount: pendingCount,
          onRetry: widget.onRetry,
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context, bool isOnline, int pendingCount) {
    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            if (_controller.isDismissed) {
              return const SizedBox.shrink();
            }

            return FadeTransition(
              opacity: _fadeAnimation,
              child: child,
            );
          },
          child: _OverlayContent(
            message: widget.message,
            retryLabel: widget.retryLabel,
            showRetry: widget.showRetry,
            showPendingCount: widget.showPendingCount,
            pendingCount: pendingCount,
            onRetry: widget.onRetry,
          ),
        ),
      ],
    );
  }
}

class _BannerContent extends StatelessWidget {
  const _BannerContent({
    required this.message,
    required this.retryLabel,
    required this.showRetry,
    required this.showPendingCount,
    required this.pendingCount,
    required this.onRetry,
    required this.position,
  });

  final String message;
  final String retryLabel;
  final bool showRetry;
  final bool showPendingCount;
  final int pendingCount;
  final VoidCallback? onRetry;
  final OfflineBannerPosition position;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: position == OfflineBannerPosition.top
            ? MediaQuery.of(context).padding.top + 8
            : 8,
        bottom: position == OfflineBannerPosition.bottom
            ? MediaQuery.of(context).padding.bottom + 8
            : 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.grey.shade800,
            Colors.grey.shade700,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: position == OfflineBannerPosition.top
                ? const Offset(0, 2)
                : const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (showPendingCount && pendingCount > 0)
                  Text(
                    '$pendingCount actions will sync when online',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
          if (showRetry && onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text(retryLabel),
            ),
        ],
      ),
    );
  }
}

class _SnackbarContent extends StatelessWidget {
  const _SnackbarContent({
    required this.message,
    required this.retryLabel,
    required this.showRetry,
    required this.showPendingCount,
    required this.pendingCount,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final bool showRetry;
  final bool showPendingCount;
  final int pendingCount;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (showPendingCount && pendingCount > 0)
                  Text(
                    '$pendingCount pending',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
          if (showRetry && onRetry != null)
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              color: Colors.white,
              iconSize: 22,
            ),
        ],
      ),
    );
  }
}

class _OverlayContent extends StatelessWidget {
  const _OverlayContent({
    required this.message,
    required this.retryLabel,
    required this.showRetry,
    required this.showPendingCount,
    required this.pendingCount,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final bool showRetry;
  final bool showPendingCount;
  final int pendingCount;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.primaryGreen],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Some features may be limited',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              if (showPendingCount && pendingCount > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.sync_rounded,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$pendingCount actions pending',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (showRetry && onRetry != null) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(retryLabel),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A wrapper that shows offline banner above content.
///
/// ```dart
/// OfflineBannerWrapper(
///   child: Scaffold(...),
/// )
/// ```
class OfflineBannerWrapper extends StatelessWidget {
  /// Creates an offline banner wrapper.
  const OfflineBannerWrapper({
    super.key,
    required this.child,
    this.onRetry,
    this.position = OfflineBannerPosition.top,
  });

  /// Content to wrap.
  final Widget child;

  /// Callback when retry is pressed.
  final VoidCallback? onRetry;

  /// Position of the banner.
  final OfflineBannerPosition position;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (position == OfflineBannerPosition.top)
          OfflineBanner(
            onRetry: onRetry,
            position: position,
          ),
        Expanded(child: child),
        if (position == OfflineBannerPosition.bottom)
          OfflineBanner(
            onRetry: onRetry,
            position: position,
          ),
      ],
    );
  }
}
