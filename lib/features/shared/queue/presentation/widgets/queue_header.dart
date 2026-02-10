/// Queue Header - Header widget for the queue screen.
///
/// Displays route information, total vehicles count, and refresh button.
library;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Header widget displaying route info and queue summary.
///
/// Shows the route name, destination, total vehicles in queue,
/// and provides a refresh action.
class QueueHeader extends StatelessWidget {
  /// Creates a QueueHeader widget.
  const QueueHeader({
    super.key,
    required this.routeName,
    required this.totalVehicles,
    this.origin,
    this.destination,
    this.onRefresh,
    this.isRefreshing = false,
  });

  /// Name of the route.
  final String routeName;

  /// Total number of vehicles in queue.
  final int totalVehicles;

  /// Route origin point.
  final String? origin;

  /// Route destination point.
  final String? destination;

  /// Callback when refresh button is pressed.
  final VoidCallback? onRefresh;

  /// Whether a refresh is currently in progress.
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route name and refresh button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.route,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Route info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routeName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (origin != null && destination != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '$origin  ->  $destination',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.grey[400]
                              : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Refresh button
              if (onRefresh != null)
                _RefreshButton(
                  onPressed: isRefreshing ? null : onRefresh,
                  isRefreshing: isRefreshing,
                  isDark: isDark,
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Divider
          Divider(
            height: 1,
            color: isDark ? Colors.grey[700] : Colors.grey[200],
          ),
          const SizedBox(height: 16),

          // Vehicle count
          Row(
            children: [
              Icon(
                Icons.directions_bus,
                size: 20,
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                '$totalVehicles ${totalVehicles == 1 ? 'vehicle' : 'vehicles'} in queue',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[300] : AppColors.textPrimary,
                ),
              ),
              const Spacer(),

              // Status indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: totalVehicles > 0
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: totalVehicles > 0
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      totalVehicles > 0 ? 'Active' : 'Empty',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: totalVehicles > 0
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Animated refresh button widget.
class _RefreshButton extends StatelessWidget {
  const _RefreshButton({
    required this.onPressed,
    required this.isRefreshing,
    required this.isDark,
  });

  final VoidCallback? onPressed;
  final bool isRefreshing;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? Colors.grey[800] : Colors.grey[100],
          ),
          child: isRefreshing
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryBlue,
                  ),
                )
              : Icon(
                  Icons.refresh,
                  size: 24,
                  color: isDark ? Colors.grey[300] : AppColors.textSecondary,
                ),
        ),
      ),
    );
  }
}
