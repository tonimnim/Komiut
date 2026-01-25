/// Offline Aware Button - Button that adapts to connectivity state.
///
/// Provides a button that:
/// - Disables when offline with informative message
/// - Shows offline indicator
/// - Can optionally queue actions for later sync
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/connectivity_providers.dart';
import '../buttons/app_button.dart';

/// Behavior when button is pressed while offline.
enum OfflineBehavior {
  /// Disable the button completely.
  disable,

  /// Show a message but allow tap (for queueing).
  allowWithWarning,

  /// Allow tap silently (handle offline in callback).
  allow,
}

/// An button that is aware of offline state.
///
/// ```dart
/// OfflineAwareButton(
///   label: 'Book Trip',
///   onPressed: () => bookTrip(),
///   offlineMessage: 'Cannot book while offline',
/// )
/// ```
class OfflineAwareButton extends ConsumerWidget {
  /// Creates an offline-aware button.
  const OfflineAwareButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.offlineBehavior = OfflineBehavior.disable,
    this.offlineMessage = 'Requires internet connection',
    this.onOfflinePressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.iconPosition = IconPosition.leading,
    this.requireStableConnection = false,
  });

  /// Creates a primary offline-aware button.
  const OfflineAwareButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.offlineBehavior = OfflineBehavior.disable,
    this.offlineMessage = 'Requires internet connection',
    this.onOfflinePressed,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.iconPosition = IconPosition.leading,
    this.requireStableConnection = false,
  }) : variant = ButtonVariant.primary;

  /// Creates an outlined offline-aware button.
  const OfflineAwareButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.offlineBehavior = OfflineBehavior.disable,
    this.offlineMessage = 'Requires internet connection',
    this.onOfflinePressed,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.iconPosition = IconPosition.leading,
    this.requireStableConnection = false,
  }) : variant = ButtonVariant.outlined;

  /// Button label.
  final String label;

  /// Callback when pressed while online.
  final VoidCallback? onPressed;

  /// Behavior when offline.
  final OfflineBehavior offlineBehavior;

  /// Message to show when offline.
  final String offlineMessage;

  /// Callback when pressed while offline (for allowWithWarning).
  final VoidCallback? onOfflinePressed;

  /// Button variant.
  final ButtonVariant variant;

  /// Button size.
  final ButtonSize size;

  /// Whether button is loading.
  final bool isLoading;

  /// Whether to fill parent width.
  final bool isFullWidth;

  /// Optional icon.
  final IconData? icon;

  /// Icon position.
  final IconPosition iconPosition;

  /// Whether to require stable (not just any) connection.
  final bool requireStableConnection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineStateProvider);
    final isStable = ref.watch(isConnectionStableProvider);

    final isAvailable = requireStableConnection ? isStable : isOnline;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isFullWidth ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        AppButton(
          label: label,
          onPressed: _getOnPressed(context, isAvailable),
          variant: variant,
          size: size,
          isLoading: isLoading,
          isFullWidth: isFullWidth,
          icon: icon,
          iconPosition: iconPosition,
        ),
        if (!isAvailable && offlineBehavior == OfflineBehavior.disable)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _OfflineIndicator(message: offlineMessage),
          ),
      ],
    );
  }

  VoidCallback? _getOnPressed(BuildContext context, bool isAvailable) {
    if (isLoading) return null;

    if (isAvailable) {
      return onPressed;
    }

    switch (offlineBehavior) {
      case OfflineBehavior.disable:
        return null;

      case OfflineBehavior.allowWithWarning:
        return () {
          _showOfflineWarning(context);
          onOfflinePressed?.call();
        };

      case OfflineBehavior.allow:
        return onPressed;
    }
  }

  void _showOfflineWarning(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.cloud_off_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(offlineMessage)),
          ],
        ),
        backgroundColor: Colors.grey.shade800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _OfflineIndicator extends StatelessWidget {
  const _OfflineIndicator({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.cloud_off_rounded,
          size: 14,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 4),
        Text(
          message,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

/// A floating action button that is aware of offline state.
class OfflineAwareFAB extends ConsumerWidget {
  /// Creates an offline-aware FAB.
  const OfflineAwareFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.offlineBehavior = OfflineBehavior.disable,
    this.offlineMessage = 'Requires internet connection',
    this.onOfflinePressed,
    this.tooltip,
    this.isExtended = false,
    this.requireStableConnection = false,
  });

  /// Callback when pressed.
  final VoidCallback? onPressed;

  /// Icon to display.
  final IconData icon;

  /// Optional label for extended FAB.
  final String? label;

  /// Behavior when offline.
  final OfflineBehavior offlineBehavior;

  /// Message to show when offline.
  final String offlineMessage;

  /// Callback when pressed while offline.
  final VoidCallback? onOfflinePressed;

  /// Tooltip text.
  final String? tooltip;

  /// Whether this is an extended FAB.
  final bool isExtended;

  /// Whether to require stable connection.
  final bool requireStableConnection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineStateProvider);
    final isStable = ref.watch(isConnectionStableProvider);
    final theme = Theme.of(context);

    final isAvailable = requireStableConnection ? isStable : isOnline;

    final Widget fab;
    if (isExtended && label != null) {
      fab = FloatingActionButton.extended(
        onPressed: _getOnPressed(context, isAvailable),
        icon: Icon(icon),
        label: Text(label!),
        tooltip: tooltip,
        backgroundColor:
            isAvailable ? null : theme.colorScheme.surfaceContainerHighest,
        foregroundColor: isAvailable
            ? null
            : theme.colorScheme.onSurface.withValues(alpha: 0.5),
      );
    } else {
      fab = FloatingActionButton(
        onPressed: _getOnPressed(context, isAvailable),
        tooltip: tooltip,
        backgroundColor:
            isAvailable ? null : theme.colorScheme.surfaceContainerHighest,
        foregroundColor: isAvailable
            ? null
            : theme.colorScheme.onSurface.withValues(alpha: 0.5),
        child: Icon(icon),
      );
    }

    if (!isAvailable) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          fab,
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        ],
      );
    }

    return fab;
  }

  VoidCallback? _getOnPressed(BuildContext context, bool isAvailable) {
    if (isAvailable) return onPressed;

    switch (offlineBehavior) {
      case OfflineBehavior.disable:
        return null;

      case OfflineBehavior.allowWithWarning:
        return () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(offlineMessage)),
                ],
              ),
              backgroundColor: Colors.grey.shade800,
              behavior: SnackBarBehavior.floating,
            ),
          );
          onOfflinePressed?.call();
        };

      case OfflineBehavior.allow:
        return onPressed;
    }
  }
}

/// A widget that shows different content based on online/offline state.
class OfflineAwareContent extends ConsumerWidget {
  /// Creates an offline-aware content widget.
  const OfflineAwareContent({
    super.key,
    required this.onlineBuilder,
    required this.offlineBuilder,
    this.requireStableConnection = false,
  });

  /// Builder for online content.
  final Widget Function(BuildContext context) onlineBuilder;

  /// Builder for offline content.
  final Widget Function(BuildContext context) offlineBuilder;

  /// Whether to require stable connection.
  final bool requireStableConnection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineStateProvider);
    final isStable = ref.watch(isConnectionStableProvider);

    final isAvailable = requireStableConnection ? isStable : isOnline;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isAvailable
          ? KeyedSubtree(
              key: const ValueKey('online'),
              child: onlineBuilder(context),
            )
          : KeyedSubtree(
              key: const ValueKey('offline'),
              child: offlineBuilder(context),
            ),
    );
  }
}

/// Extension for easy offline-awareness on any widget.
extension OfflineAwareExtension on Widget {
  /// Wraps this widget to show a placeholder when offline.
  Widget offlineAware({
    required Widget placeholder,
    bool requireStableConnection = false,
  }) {
    return OfflineAwareContent(
      onlineBuilder: (_) => this,
      offlineBuilder: (_) => placeholder,
      requireStableConnection: requireStableConnection,
    );
  }
}
