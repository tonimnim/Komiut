/// Suggested Saccos Section for home screen.
///
/// Displays a horizontal scrollable list of suggested/featured Saccos
/// for quick discovery from the home screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading/shimmer_loading.dart';
import '../../../passenger/discovery/domain/entities/sacco.dart';
import '../../../passenger/discovery/presentation/providers/sacco_providers.dart';

/// Section displaying suggested Saccos on the home screen.
///
/// Shows a horizontal scrollable list of 3-5 sacco cards with a
/// "View All" button that navigates to the full saccos list.
class SuggestedSaccosSection extends ConsumerWidget {
  /// Creates a SuggestedSaccosSection.
  const SuggestedSaccosSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saccosAsync = ref.watch(saccosProvider);
    final theme = Theme.of(context);

    return saccosAsync.when(
      data: (saccos) {
        // Filter to only active saccos and take first 5
        final activeSaccos = saccos.where((s) => s.isActive).take(5).toList();

        // Don't show section if no active saccos
        if (activeSaccos.isEmpty) {
          return const SizedBox.shrink();
        }

        return _buildSection(context, ref, theme, activeSaccos);
      },
      loading: () => _buildLoadingState(context, theme),
      error: (_, __) => const SizedBox.shrink(), // Hide section on error
    );
  }

  Widget _buildSection(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    List<Sacco> saccos,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Suggested Saccos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {
                context.push(RouteConstants.passengerSaccos);
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontal scrollable list
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: saccos.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _SaccoCompactCard(
                sacco: saccos[index],
                onTap: () {
                  context.push(
                    RouteConstants.passengerSaccoDetailPath(saccos[index].id),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header shimmer
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShimmerBox(height: 18, width: 140),
            ShimmerBox(height: 16, width: 60, borderRadius: 4),
          ],
        ),
        const SizedBox(height: 12),

        // Cards shimmer
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return Container(
                width: 160,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: isDark ? 0.3 : 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerCircle(size: 40),
                    SizedBox(height: 12),
                    ShimmerBox(height: 14, width: 100),
                    SizedBox(height: 8),
                    ShimmerBox(height: 12, width: 70),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Compact Sacco card for horizontal list display.
class _SaccoCompactCard extends StatelessWidget {
  const _SaccoCompactCard({
    required this.sacco,
    this.onTap,
  });

  final Sacco sacco;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                _buildLogo(theme, isDark),
                const SizedBox(height: 12),

                // Name
                Text(
                  sacco.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Route count
                Row(
                  children: [
                    Icon(
                      Icons.route_outlined,
                      size: 12,
                      color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${sacco.routeCount} ${sacco.routeCount == 1 ? 'route' : 'routes'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Active indicator
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Active',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(ThemeData theme, bool isDark) {
    if (sacco.hasLogo) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? Colors.grey[800] : Colors.grey[100],
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          sacco.logoUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderLogo(theme, isDark);
          },
        ),
      );
    }

    return _buildPlaceholderLogo(theme, isDark);
  }

  Widget _buildPlaceholderLogo(ThemeData theme, bool isDark) {
    final initial = sacco.name.isNotEmpty ? sacco.name[0].toUpperCase() : 'S';

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue.withValues(alpha: isDark ? 0.3 : 0.15),
            AppColors.primaryGreen.withValues(alpha: isDark ? 0.3 : 0.15),
          ],
        ),
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryBlue, AppColors.primaryGreen],
          ).createShader(bounds),
          child: Text(
            initial,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
