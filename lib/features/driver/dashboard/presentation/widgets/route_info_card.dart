/// Route Info Card Widget.
///
/// Shows the driver's assigned route information including
/// origin, destination, route number, and sacco details.
library;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/cards/app_card.dart';

/// Card displaying assigned route information.
///
/// Shows route origin/destination, route number, and sacco name.
/// Use this widget by passing in route data rather than watching providers.
class RouteInfoCard extends StatelessWidget {
  const RouteInfoCard({
    super.key,
    required this.origin,
    required this.destination,
    this.routeNumber,
    this.saccoName,
    this.onTap,
  });

  /// Origin/starting point of the route.
  final String origin;

  /// Destination/ending point of the route.
  final String destination;

  /// Route number or code (e.g., "102").
  final String? routeNumber;

  /// Sacco or operator name.
  final String? saccoName;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppColors.primaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Route information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Route path
                Text(
                  '$origin \u2192 $destination',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Route details
                _buildDetailsRow(theme),
              ],
            ),
          ),
          // Chevron for tap indication
          if (onTap != null)
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 24,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsRow(ThemeData theme) {
    final hasRouteNumber = routeNumber != null && routeNumber!.isNotEmpty;
    final hasSaccoName = saccoName != null && saccoName!.isNotEmpty;

    if (!hasRouteNumber && !hasSaccoName) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (hasRouteNumber)
          Text(
            'Route $routeNumber',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        if (hasRouteNumber && hasSaccoName) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.textMuted,
              shape: BoxShape.circle,
            ),
          ),
        ],
        if (hasSaccoName)
          Flexible(
            child: Text(
              saccoName!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

/// Compact version of route info card for smaller spaces.
class RouteInfoCardCompact extends StatelessWidget {
  const RouteInfoCardCompact({
    super.key,
    required this.origin,
    required this.destination,
    this.routeNumber,
    this.onTap,
  });

  /// Origin/starting point of the route.
  final String origin;

  /// Destination/ending point of the route.
  final String destination;

  /// Route number or code.
  final String? routeNumber;

  /// Callback when tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.pillBlueBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on_rounded,
              color: AppColors.primaryBlue,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              '$origin \u2192 $destination',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (routeNumber != null) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                routeNumber!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryBlue.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Route info card with visual route line indicator.
class RouteInfoCardWithLine extends StatelessWidget {
  const RouteInfoCardWithLine({
    super.key,
    required this.origin,
    required this.destination,
    this.routeNumber,
    this.saccoName,
    this.estimatedDuration,
    this.onTap,
  });

  /// Origin/starting point of the route.
  final String origin;

  /// Destination/ending point of the route.
  final String destination;

  /// Route number or code.
  final String? routeNumber;

  /// Sacco or operator name.
  final String? saccoName;

  /// Estimated trip duration.
  final String? estimatedDuration;

  /// Callback when tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route header
          if (routeNumber != null || saccoName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  if (routeNumber != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        routeNumber!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (routeNumber != null && saccoName != null)
                    const SizedBox(width: 8),
                  if (saccoName != null)
                    Expanded(
                      child: Text(
                        saccoName!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          // Route line visualization
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route line indicator
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryBlue.withValues(alpha: 0.3),
                        width: 3,
                      ),
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 28,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryGreen.withValues(alpha: 0.3),
                        width: 3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Origin and destination text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      origin,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      destination,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Duration if provided
          if (estimatedDuration != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    estimatedDuration!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
