import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/route_entity.dart';
import '../providers/route_providers.dart';
import 'booking_screen.dart';

class RoutesScreen extends ConsumerWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final routesAsync = ref.watch(advancedFilteredRoutesProvider);
    final searchQuery = ref.watch(
      routeFilterStateProvider.select((s) => s.searchQuery ?? ''),
    );

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: TextField(
            onChanged: (value) {
              ref.read(routeFilterStateProvider.notifier).state =
                  ref.read(routeFilterStateProvider).copyWith(
                    searchQuery: value,
                    clearSearchQuery: value.isEmpty,
                  );
            },
            style: TextStyle(
              fontSize: 15,
              color: theme.colorScheme.onSurface,
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
                size: 20,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: isDark
                    ? BorderSide(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 1,
                      )
                    : BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primaryBlue.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Routes list
        Expanded(
          child: routesAsync.when(
            data: (routes) {
              if (routes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        searchQuery.isNotEmpty
                            ? Icons.search_off
                            : Icons.route_outlined,
                        size: 48,
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        searchQuery.isNotEmpty
                            ? 'No routes found'
                            : 'No routes available',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? Colors.grey[400]
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                itemCount: routes.length,
                itemBuilder: (context, index) {
                  final route = routes[index];
                  return _RouteTile(
                    route: route,
                    showDivider: index < routes.length - 1,
                    onTap: () {
                      ref.read(selectedRouteProvider.notifier).state = route;
                      ref.read(bookingStateProvider.notifier).reset();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BookingScreen(),
                        ),
                      );
                    },
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            ),
            error: (_, __) => Center(
              child: Text(
                'Failed to load routes',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RouteTile extends StatelessWidget {
  final RouteEntity route;
  final bool showDivider;
  final VoidCallback onTap;

  const _RouteTile({
    required this.route,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        route.routeSummary,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.grey[400]
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.grey[600] : AppColors.textHint,
                  size: 20,
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              color: isDark ? Colors.grey[800] : AppColors.divider,
            ),
        ],
      ),
    );
  }
}
