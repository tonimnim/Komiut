/// Popular Routes Section - Horizontal scrollable list of popular routes.
///
/// Displays a curated list of popular/featured routes in a horizontal
/// scrollable format. Each route card shows key information and allows
/// navigation to booking.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading/shimmer_loading.dart';
import '../../domain/entities/route_entity.dart';
import '../providers/route_providers.dart';

/// A horizontal scrollable section displaying popular routes.
///
/// Shows a list of popular route cards that users can scroll through.
/// Tapping a card navigates to the booking flow.
class PopularRoutesSection extends ConsumerWidget {
  /// Creates a PopularRoutesSection.
  const PopularRoutesSection({
    super.key,
    this.onRouteTap,
    this.title = 'Popular Routes',
    this.showSeeAll = true,
    this.onSeeAllTap,
  });

  /// Callback when a route card is tapped.
  final void Function(RouteEntity route)? onRouteTap;

  /// Section title.
  final String title;

  /// Whether to show the "See all" button.
  final bool showSeeAll;

  /// Callback when "See all" is tapped.
  final VoidCallback? onSeeAllTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popularRoutesAsync = ref.watch(popularRoutesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return popularRoutesAsync.when(
      data: (routes) {
        // Hide section if empty
        if (routes.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                    ),
                  ),
                  if (showSeeAll)
                    GestureDetector(
                      onTap: onSeeAllTap,
                      child: const Text(
                        'See all',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Horizontal scrollable list
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: routes.length,
                itemBuilder: (context, index) {
                  final route = routes[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _PopularRouteCard(
                      route: route,
                      onTap: () {
                        if (onRouteTap != null) {
                          onRouteTap!(route);
                        } else {
                          // Default behavior: navigate to booking
                          ref.read(selectedRouteProvider.notifier).state = route;
                          ref.read(bookingStateProvider.notifier).reset();
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => _buildShimmerLoading(isDark),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildShimmerLoading(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: ShimmerBox(
            width: 120,
            height: 18,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return const Padding(
                padding: EdgeInsets.only(right: 12),
                child: ShimmerCard(
                  width: 200,
                  height: 140,
                  margin: EdgeInsets.zero,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Individual popular route card.
class _PopularRouteCard extends StatelessWidget {
  const _PopularRouteCard({
    required this.route,
    required this.onTap,
  });

  final RouteEntity route;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            width: 1,
          ),
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
            // Route name
            Row(
              children: [
                const Icon(
                  Icons.directions_bus,
                  color: AppColors.primaryBlue,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    route.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Route summary (origin -> destination)
            Text(
              route.routeSummary,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const Spacer(),

            // Bottom row: price and duration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    route.formattedBaseFare,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),

                // Duration
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: isDark ? Colors.grey[500] : AppColors.textHint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      route.formattedDuration,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
