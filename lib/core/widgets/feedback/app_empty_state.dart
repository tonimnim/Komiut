/// AppEmptyState - Empty state display component.
///
/// Widget for displaying empty states with optional action.
library;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../buttons/app_button.dart';

/// Types of empty states that can be displayed.
enum EmptyStateType {
  /// No data available.
  noData,

  /// No search results found.
  noResults,

  /// No connection/offline state.
  noConnection,

  /// Feature not available.
  notAvailable,

  /// Custom empty state.
  custom,
}

/// A standardized empty state display widget.
///
/// ```dart
/// AppEmptyState(
///   title: 'No Trips Yet',
///   message: 'Book your first trip to get started',
///   type: EmptyStateType.noData,
///   action: AppButton.primary(
///     label: 'Book Now',
///     onPressed: () => _navigateToBooking(),
///   ),
/// )
/// ```
class AppEmptyState extends StatelessWidget {
  /// Creates an AppEmptyState widget.
  const AppEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.action,
    this.type = EmptyStateType.custom,
    this.illustration,
    this.compact = false,
    this.useGradientIcon = false,
  });

  /// Creates an empty list state.
  factory AppEmptyState.noItems({
    Key? key,
    String title = 'Nothing Here Yet',
    String? message = 'No items to display',
    Widget? action,
    Widget? illustration,
    bool compact = false,
  }) {
    return AppEmptyState(
      key: key,
      title: title,
      message: message,
      type: EmptyStateType.noData,
      action: action,
      illustration: illustration,
      compact: compact,
    );
  }

  /// Creates a no results state.
  factory AppEmptyState.noResults({
    Key? key,
    String title = 'No Results Found',
    String? message = 'Try adjusting your search or filters',
    Widget? action,
    bool compact = false,
  }) {
    return AppEmptyState(
      key: key,
      title: title,
      message: message,
      type: EmptyStateType.noResults,
      action: action,
      compact: compact,
    );
  }

  /// Creates a no connection state.
  factory AppEmptyState.noConnection({
    Key? key,
    String title = 'You\'re Offline',
    String? message = 'Check your internet connection and try again',
    Widget? action,
    bool compact = false,
  }) {
    return AppEmptyState(
      key: key,
      title: title,
      message: message,
      type: EmptyStateType.noConnection,
      action: action,
      compact: compact,
    );
  }

  /// Creates a no trips state.
  factory AppEmptyState.noTrips({
    Key? key,
    String title = 'No Trips Yet',
    String? message = 'Book your first trip to get started!',
    VoidCallback? onAction,
    bool compact = false,
  }) {
    return AppEmptyState(
      key: key,
      title: title,
      message: message,
      icon: Icons.directions_bus_outlined,
      type: EmptyStateType.noData,
      action: onAction != null
          ? AppButton.primary(
              label: 'Book a Trip',
              onPressed: onAction,
            )
          : null,
      compact: compact,
      useGradientIcon: true,
    );
  }

  /// Creates an empty wallet state.
  factory AppEmptyState.noTransactions({
    Key? key,
    String title = 'No Transactions',
    String? message = 'Your transaction history will appear here',
    VoidCallback? onAction,
    bool compact = false,
  }) {
    return AppEmptyState(
      key: key,
      title: title,
      message: message,
      icon: Icons.receipt_long_outlined,
      type: EmptyStateType.noData,
      action: onAction != null
          ? AppButton.primary(
              label: 'Add Funds',
              onPressed: onAction,
            )
          : null,
      compact: compact,
    );
  }

  /// Creates a feature not available state.
  factory AppEmptyState.notAvailable({
    Key? key,
    String title = 'Coming Soon',
    String? message = 'This feature is not available yet',
    Widget? action,
    bool compact = false,
  }) {
    return AppEmptyState(
      key: key,
      title: title,
      message: message,
      type: EmptyStateType.notAvailable,
      action: action,
      compact: compact,
    );
  }

  /// Title to display.
  final String title;

  /// Optional message to display.
  final String? message;

  /// Custom icon to display.
  final IconData? icon;

  /// Optional action widget (usually a button).
  final Widget? action;

  /// Type of empty state for icon selection.
  final EmptyStateType type;

  /// Optional illustration widget to replace the icon.
  final Widget? illustration;

  /// Whether to use compact layout.
  final bool compact;

  /// Whether to use gradient colored icon.
  final bool useGradientIcon;

  /// Get the appropriate icon for the empty state type.
  IconData get _icon {
    if (icon != null) return icon!;
    switch (type) {
      case EmptyStateType.noData:
        return Icons.inbox_outlined;
      case EmptyStateType.noResults:
        return Icons.search_off_rounded;
      case EmptyStateType.noConnection:
        return Icons.cloud_off_rounded;
      case EmptyStateType.notAvailable:
        return Icons.hourglass_empty_rounded;
      case EmptyStateType.custom:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconSize = compact ? 48.0 : 80.0;
    final spacing = compact ? 12.0 : 16.0;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 16 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustration != null)
              illustration!
            else
              _buildIcon(theme, iconSize),
            SizedBox(height: spacing),
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              SizedBox(height: spacing * 1.5),
              action!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme, double size) {
    if (useGradientIcon) {
      return Container(
        padding: EdgeInsets.all(compact ? 12 : 20),
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
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryBlue, AppColors.primaryGreen],
          ).createShader(bounds),
          child: Icon(
            _icon,
            size: size,
            color: Colors.white,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
      ),
      child: Icon(
        _icon,
        size: size,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
      ),
    );
  }
}
