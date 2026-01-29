/// Nearby Routes Section - Location-based route discovery.
///
/// Displays routes that have stops near the user's current location.
/// Uses GPS to determine proximity and shows relevant routes in a
/// horizontal scrollable format.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading/shimmer_loading.dart';
import '../../domain/entities/route_entity.dart';
import '../providers/location_providers.dart';
import '../providers/route_providers.dart';

/// A horizontal scrollable section displaying routes near the user.
///
/// Shows routes that have stops within a configurable radius of the
/// user's current location. Requires location permissions to function.
class NearbyRoutesSection extends ConsumerWidget {
  /// Creates a NearbyRoutesSection.
  const NearbyRoutesSection({
    super.key,
    this.onRouteTap,
    this.title = 'Nearby Routes',
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
    final locationAsync = ref.watch(currentLocationProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return locationAsync.when(
      data: (location) {
        if (location == null) {
          // Location not available - show prompt to enable
          return _buildLocationPrompt(context, ref, isDark);
        }

        // We have location, now show nearby routes
        return _NearbyRoutesContent(
          location: location,
          onRouteTap: onRouteTap,
          title: title,
          showSeeAll: showSeeAll,
          onSeeAllTap: onSeeAllTap,
        );
      },
      loading: () => _buildShimmerLoading(isDark),
      error: (error, _) => _buildLocationError(context, ref, isDark, error),
    );
  }

  Widget _buildLocationPrompt(BuildContext context, WidgetRef ref, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.location_on,
                color: AppColors.primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enable Location',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Find routes near you',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(locationServiceProvider).requestPermission();
                ref.invalidate(currentLocationProvider);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
              ),
              child: const Text('Enable'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationError(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    Object error,
  ) {
    final isPermissionDenied = error.toString().contains('permission');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isPermissionDenied ? Icons.location_disabled : Icons.error_outline,
                color: AppColors.warning,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPermissionDenied ? 'Location Access Denied' : 'Location Unavailable',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isPermissionDenied
                        ? 'Allow location access in settings'
                        : 'Unable to get your location',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                if (isPermissionDenied) {
                  ref.read(locationServiceProvider).openSettings();
                } else {
                  ref.invalidate(currentLocationProvider);
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
              ),
              child: Text(isPermissionDenied ? 'Settings' : 'Retry'),
            ),
          ],
        ),
      ),
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

/// Content widget that displays nearby routes once location is available.
class _NearbyRoutesContent extends ConsumerWidget {
  const _NearbyRoutesContent({
    required this.location,
    this.onRouteTap,
    this.title = 'Nearby Routes',
    this.showSeeAll = true,
    this.onSeeAllTap,
  });

  final UserLocation location;
  final void Function(RouteEntity route)? onRouteTap;
  final String title;
  final bool showSeeAll;
  final VoidCallback? onSeeAllTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyRoutesAsync = ref.watch(nearbyRoutesProvider(location));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return nearbyRoutesAsync.when(
      data: (routes) {
        // Hide section if no nearby routes
        if (routes.isEmpty) {
          return _buildNoNearbyRoutes(context, isDark);
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
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: AppColors.primaryGreen,
                            ),
                            SizedBox(width: 2),
                            Text(
                              'GPS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                    child: _NearbyRouteCard(
                      route: route,
                      onTap: () {
                        if (onRouteTap != null) {
                          onRouteTap!(route);
                        } else {
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
      loading: () => _buildLoading(isDark),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildNoNearbyRoutes(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.textHint.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.route,
                color: isDark ? Colors.grey[500] : AppColors.textHint,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No routes nearby',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Try browsing all available routes',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: ShimmerBox(
            width: 140,
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

/// Individual nearby route card with distance indicator.
class _NearbyRouteCard extends StatelessWidget {
  const _NearbyRouteCard({
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
            // Route name with nearby indicator
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.near_me,
                    color: AppColors.primaryGreen,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
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

            // Bottom row: price and stops
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

                // Stops count
                Row(
                  children: [
                    Icon(
                      Icons.place,
                      size: 14,
                      color: isDark ? Colors.grey[500] : AppColors.textHint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${route.stopsCount} stops',
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
