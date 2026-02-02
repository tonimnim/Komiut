/// Queue Empty State - Widget displayed when no vehicles are in queue.
///
/// Shows a friendly message when there are no vehicles available
/// on the selected route, with optional retry action.
library;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Empty state widget for the queue screen.
///
/// Displays when no vehicles are currently in the queue for a route.
class QueueEmptyState extends StatelessWidget {
  /// Creates a QueueEmptyState widget.
  const QueueEmptyState({
    super.key,
    this.onRefresh,
    this.routeName,
  });

  /// Callback when refresh button is pressed.
  final VoidCallback? onRefresh;

  /// Name of the route (for display purposes).
  final String? routeName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with gradient background
            Container(
              padding: const EdgeInsets.all(24),
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
                child: const Icon(
                  Icons.directions_bus_outlined,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'No Vehicles in Queue',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              routeName != null
                  ? 'There are currently no vehicles queued for $routeName. Please check back later or try another route.'
                  : 'There are currently no vehicles queued for this route. Please check back later.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Refresh button
            if (onRefresh != null)
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
