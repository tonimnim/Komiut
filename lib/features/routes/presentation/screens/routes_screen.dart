import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/route_entity.dart';
import '../providers/route_providers.dart';
import 'booking_screen.dart';

class RoutesScreen extends ConsumerWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final routesAsync = ref.watch(filteredRoutesProvider);
    final searchQuery = ref.watch(routeSearchQueryProvider);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: (value) {
                ref.read(routeSearchQueryProvider.notifier).state = value;
              },
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Search routes...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[500] : AppColors.textHint,
                  fontSize: 15,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.grey[500] : AppColors.textHint,
                  size: 22,
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryBlue,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Section title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              searchQuery.isEmpty ? 'Popular Routes' : 'Search Results',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Routes list
          Expanded(
            child: routesAsync.when(
              data: (routes) {
                if (routes.isEmpty) {
                  return _buildEmptyState(context, searchQuery);
                }
                return ListView.builder(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: routes.length,
                  itemBuilder: (context, index) {
                    final route = routes[index];
                    final isLast = index == routes.length - 1;
                    return _RouteTile(
                      route: route,
                      showDivider: !isLast,
                      onTap: () => _openBooking(context, ref, route),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryBlue,
                ),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load routes',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
    );
  }

  Widget _buildEmptyState(BuildContext context, String query) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No routes found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
          ),
          if (query.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Try a different search',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[600] : AppColors.textHint,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openBooking(BuildContext context, WidgetRef ref, RouteEntity route) {
    ref.read(selectedRouteProvider.notifier).state = route;
    ref.read(bookingStateProvider.notifier).reset();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BookingScreen(),
      ),
    );
  }
}

class _RouteTile extends ConsumerWidget {
  final RouteEntity route;
  final bool showDivider;
  final VoidCallback onTap;

  const _RouteTile({
    required this.route,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Icon(
                  Icons.directions_bus,
                  color: AppColors.primaryBlue,
                  size: 26,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            route.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          if (route.isFavorite) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.favorite,
                              size: 14,
                              color: AppColors.error,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        route.routeSummary,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${route.stopsCount} stops · ${route.formattedDuration} · from ${route.formattedBaseFare}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[500] : AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.grey[600] : AppColors.textHint,
                  size: 22,
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              thickness: 1,
              color: isDark ? Colors.grey[700] : Colors.grey[300],
            ),
        ],
      ),
    );
  }
}
