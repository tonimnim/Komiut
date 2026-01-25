/// Sacco Routes Section - Routes operated by a Sacco.
///
/// Displays a list of routes operated by a specific Sacco.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/domain/entities/route.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../routes/presentation/providers/route_providers.dart';

/// A section displaying routes operated by a Sacco.
///
/// Watches the routes provider and filters by organizationId
/// to show only routes belonging to the specified Sacco.
///
/// ```dart
/// SaccoRoutesSection(
///   saccoId: 'sacco-123',
/// )
/// ```
class SaccoRoutesSection extends ConsumerWidget {
  /// Creates a SaccoRoutesSection.
  const SaccoRoutesSection({
    super.key,
    required this.saccoId,
  });

  /// The ID of the Sacco to show routes for.
  final String saccoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(apiRoutesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return routesAsync.when(
      loading: () => const _RoutesLoadingSection(),
      error: (error, stack) => _RoutesErrorSection(
        onRetry: () => ref.invalidate(apiRoutesProvider),
      ),
      data: (routes) {
        // Filter routes by organization ID
        final saccoRoutes = routes
            .where((route) => route.organizationId == saccoId)
            .toList();

        return _RoutesList(
          routes: saccoRoutes,
          isDark: isDark,
        );
      },
    );
  }
}

/// Internal widget for displaying the routes list.
class _RoutesList extends StatelessWidget {
  const _RoutesList({
    required this.routes,
    required this.isDark,
  });

  final List<TransportRoute> routes;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Routes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${routes.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Routes list
        if (routes.isEmpty)
          _EmptyRoutesState(isDark: isDark)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: routes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final route = routes[index];
              return _RouteCard(route: route, isDark: isDark);
            },
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Internal widget for displaying a single route card.
class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.route,
    required this.isDark,
  });

  final TransportRoute route;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _navigateToRoute(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            ),
          ),
          child: Row(
            children: [
              // Route icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.route_outlined,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Route details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.displayName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${route.startPoint ?? 'Start'} -> ${route.endPoint ?? 'End'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? Colors.grey[400]
                                  : AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (route.baseFare != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            route.formattedFare,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Chevron
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToRoute(BuildContext context) {
    context.push('/routes/${route.id}');
  }
}

/// Empty state when no routes are available.
class _EmptyRoutesState extends StatelessWidget {
  const _EmptyRoutesState({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.route_outlined,
            size: 48,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'No routes available',
            style: theme.textTheme.titleSmall?.copyWith(
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This Sacco has no active routes at the moment',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.grey[500] : AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Loading state for routes section.
class _RoutesLoadingSection extends StatelessWidget {
  const _RoutesLoadingSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Routes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: 32,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ShimmerCard(height: 88, margin: EdgeInsets.zero),
              SizedBox(height: 12),
              ShimmerCard(height: 88, margin: EdgeInsets.zero),
              SizedBox(height: 12),
              ShimmerCard(height: 88, margin: EdgeInsets.zero),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Error state for routes section.
class _RoutesErrorSection extends StatelessWidget {
  const _RoutesErrorSection({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Available Routes',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.error.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 12),
              Text(
                'Failed to load routes',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
