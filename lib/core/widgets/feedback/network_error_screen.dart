/// Network Error Screen - Full-screen no internet connection display.
///
/// Shows when the app cannot connect to the internet.
library;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../buttons/app_button.dart';

/// A full-screen widget for displaying no internet connection state.
///
/// ```dart
/// NetworkErrorScreen(
///   onRetry: () => _checkConnection(),
///   onOfflineMode: () => _useOfflineData(),
/// )
/// ```
class NetworkErrorScreen extends StatelessWidget {
  /// Creates a NetworkErrorScreen.
  const NetworkErrorScreen({
    super.key,
    required this.onRetry,
    this.onOfflineMode,
    this.title = 'No Internet Connection',
    this.message = 'Please check your network settings and try again.',
    this.offlineModeLabel = 'Continue Offline',
    this.retryLabel = 'Try Again',
    this.showOfflineOption = true,
  });

  /// Callback when retry button is pressed.
  final VoidCallback onRetry;

  /// Optional callback for offline mode.
  final VoidCallback? onOfflineMode;

  /// Title text.
  final String title;

  /// Message text.
  final String message;

  /// Label for offline mode button.
  final String offlineModeLabel;

  /// Label for retry button.
  final String retryLabel;

  /// Whether to show the offline mode option.
  final bool showOfflineOption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Animated network icon
              _NetworkIcon(isDark: isDark),
              const SizedBox(height: 32),
              // Title
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Retry button
              AppButton.primary(
                label: retryLabel,
                onPressed: onRetry,
                icon: Icons.refresh_rounded,
                isFullWidth: true,
              ),
              if (showOfflineOption && onOfflineMode != null) ...[
                const SizedBox(height: 16),
                AppButton.text(
                  label: offlineModeLabel,
                  onPressed: onOfflineMode,
                  icon: Icons.cloud_off_rounded,
                ),
              ],
              const Spacer(flex: 3),
              // Connection tips
              _ConnectionTips(theme: theme),
            ],
          ),
        ),
      ),
    );
  }
}

class _NetworkIcon extends StatefulWidget {
  const _NetworkIcon({required this.isDark});

  final bool isDark;

  @override
  State<_NetworkIcon> createState() => _NetworkIconState();
}

class _NetworkIconState extends State<_NetworkIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryBlue.withValues(alpha: 0.1),
                  AppColors.primaryGreen.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
          // Middle ring
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryBlue.withValues(alpha: 0.2),
                  AppColors.primaryGreen.withValues(alpha: 0.2),
                ],
              ),
            ),
          ),
          // Inner circle with icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryBlue, AppColors.primaryGreen],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionTips extends StatelessWidget {
  const _ConnectionTips({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates_outlined,
                size: 18,
                color: AppColors.info,
              ),
              const SizedBox(width: 8),
              Text(
                'Quick tips',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TipItem(
            icon: Icons.wifi_rounded,
            text: 'Check if Wi-Fi is enabled',
            theme: theme,
          ),
          const SizedBox(height: 8),
          _TipItem(
            icon: Icons.signal_cellular_alt_rounded,
            text: 'Check your mobile data connection',
            theme: theme,
          ),
          const SizedBox(height: 8),
          _TipItem(
            icon: Icons.flight_rounded,
            text: 'Turn off airplane mode',
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  const _TipItem({
    required this.icon,
    required this.text,
    required this.theme,
  });

  final IconData icon;
  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}

/// A compact network error banner for inline use.
///
/// Shows at the top or bottom of a screen when offline.
class NetworkErrorBanner extends StatelessWidget {
  /// Creates a NetworkErrorBanner.
  const NetworkErrorBanner({
    super.key,
    this.onRetry,
    this.message = 'No internet connection',
    this.showRetry = true,
  });

  /// Callback when retry is tapped.
  final VoidCallback? onRetry;

  /// Message to display.
  final String message;

  /// Whether to show retry button.
  final bool showRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.primaryBlue, AppColors.primaryGreen],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            if (showRetry && onRetry != null)
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }
}
